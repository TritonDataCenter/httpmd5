# httpmd5: convert between md5sum representations

`httpmd5` converts back and forth between md5sums used in HTTP (which are
base64-encoded representations of the underlying bits) and those reported by the
md5(1) and digest(1) commands (which are hex representations of the underlying
bits).

Any of the following may be provided on stdin:

- a base64-encoded string (as found inside HTTP responses)
- a hex-encoded string (as output by the md5(1) and digest(1) tools)
- a line from an HTTP response containing only the "content-md5" header
- complete HTTP response headers
- a complete HTTP response

This tool reads up to a fixed amount of input (expected to be large enough for
all reasonable cases), attempts to figure out which of these types of input
you've provided, extracts the relevant substring if necessary (e.g., the value
of the "content-md5" header), parses it based on whatever type it appears to be,
and then prints out both the hex and base64-encoded representations.

Currently, `httpmd5` attempts to determine the input type as follows:

- If there is more than one line in the input, the input is assumed to be either
  a block of HTTP response headers or an entire HTTP response.  If the first
  line is inconsistent with that, we bail out.  Otherwise, we continue reading
  until we find a "content-md5" line, an end of the headers, or reach a
  predefined byte limit.  If we find a "content-md5 line", we treat it as though
  that were the only line provided as input.
- If the single input line starts with "content-md5", then we extract the input
  string from the value of that header and assume that it's base64-encoded.
- Otherwise, if the single input line contains exactly 32 hex digits, we assume
  the string is hex-encoded.  Otherwise, we assume that it's base64-encoded.


## Installation

    npm install -g httpmd5

## Examples

Suppose we have an HTTP resource whose HEAD response looks like this:

    $ curl -s -I https://us-east.manta.joyent.com/poseidon/public/agent.sh
    HTTP/1.1 200 OK
    Connection: close
    Etag: 0d8c8d20-2e04-cafd-c3b3-b2c432ab6a1c
    Last-Modified: Fri, 04 Dec 2015 23:45:09 GMT
    access-control-allow-origin: *
    Durability-Level: 2
    Content-Length: 17
    Content-MD5: +8JLzHoXlHWPwTJ/z+va9g==
    Content-Type: application/json
    Date: Fri, 30 Mar 2018 22:57:00 GMT
    Server: Manta
    x-request-id: a77432d0-346d-11e8-b92d-21ef0483406a
    x-response-time: 135
    x-server-name: 3d2b5d91-5cd9-4123-89a5-794f44eab9fd

The md5sum of the content is represented by the base64-encoded string
`+8JLzHoXlHWPwTJ/z+va9g==`.  We can see the hex-encoded representation by
providing either the whole set of headers:

    $ curl -s -I https://us-east.manta.joyent.com/poseidon/public/agent.sh | httpmd5
    input string:   +8JLzHoXlHWPwTJ/z+va9g==
    input encoding: base64
    base64-encoded: +8JLzHoXlHWPwTJ/z+va9g==
    hex-encoded:    fbc24bcc7a1794758fc1327fcfebdaf6

or the whole response:

    $ curl -s -i https://us-east.manta.joyent.com/poseidon/public/agent.sh | httpmd5
    input string:   +8JLzHoXlHWPwTJ/z+va9g==
    input encoding: base64
    base64-encoded: +8JLzHoXlHWPwTJ/z+va9g==
    hex-encoded:    fbc24bcc7a1794758fc1327fcfebdaf6

or just the content-md5 header:

    $ curl -s -i https://us-east.manta.joyent.com/poseidon/public/agent.sh | grep -i content-md5 | httpmd5 
    input string:   +8JLzHoXlHWPwTJ/z+va9g==
    input encoding: base64
    base64-encoded: +8JLzHoXlHWPwTJ/z+va9g==
    hex-encoded:    fbc24bcc7a1794758fc1327fcfebdaf6

or just the string itself:

    $ echo "+8JLzHoXlHWPwTJ/z+va9g==" | httpmd5
    input string:   +8JLzHoXlHWPwTJ/z+va9g==
    input encoding: base64
    base64-encoded: +8JLzHoXlHWPwTJ/z+va9g==
    hex-encoded:    fbc24bcc7a1794758fc1327fcfebdaf6
    
As we'd expect, these all produce the same output, which is the hex string
`fbc24bcc7a1794758fc1327fcfebdaf6`.  We can see this by fetching the same
resource and manually checking the md5sum:

    $ curl -s https://us-east.manta.joyent.com/poseidon/public/agent.sh | md5 
    fbc24bcc7a1794758fc1327fcfebdaf6


## Hand-checking

Given a base64-encoded md5sum like `+8JLzHoXlHWPwTJ/z+va9g==`, you can generate
the hex value by decoding the value with the `openssl base64 -d` command and
then formatting the resulting raw bytes with `xxd -p`:

    $ echo "+8JLzHoXlHWPwTJ/z+va9g==" | openssl base64 -d | xxd -p
    fbc24bcc7a1794758fc1327fcfebdaf6

Given a hex-encoded value like "fbc24bcc7a1794758fc1327fcfebdaf6", you can
produce the base64-encoded value by using `xxd -r -p` to decode the hex
representation and then encoding the resulting raw bytes with `openssl base64`:

    $ echo fbc24bcc7a1794758fc1327fcfebdaf6 | xxd -r -p | openssl base64
    +8JLzHoXlHWPwTJ/z+va9g==


## TODO

- could support HTTP requests as input, too
- test (and fix) cases where the input exceeds the maximum and the last byte is
  a non-final byte of a multi-byte UTF-8 character
