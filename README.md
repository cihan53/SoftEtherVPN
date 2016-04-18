# A simple single-user [SoftEther VPN][1] server Docker image

[![Travis](https://img.shields.io/travis/siomiz/SoftEtherVPN/master.svg?style=flat-square)]()
<!--- [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/siomiz/softethervpn/latest.svg?style=flat-square)]() -->

**Note:** OpenVPN support is enabled on :latest image. STDOUT (`docker log`) format has changed as a result.

## Setup
 - L2TP/IPSec PSK + OpenVPN
 - SecureNAT enabled
 - Perfect Forward Secrecy (DHE-RSA-AES256-SHA)
 - make'd from [the official SoftEther VPN GitHub repo][2] master (Note: they don't have any other branches or tags.)

`docker run -d --cap-add NET_ADMIN -p 500:500/udp -p 4500:4500/udp -p 1701:1701/tcp -p 1194:1194/udp siomiz/softethervpn`

Connectivity tested on Android + iOS devices. It seems Android devices do not require L2TP server to have port 1701/tcp open.

The above example will accept connections from both L2TP/IPSec and OpenVPN clients at the same time.

Mix and match published ports: 
- `-p 500:500/udp -p 4500:4500/udp -p 1701:1701/tcp` for L2TP/IPSec
- `-p 1194:1194/udp` for OpenVPN.

## Credentials

All optional:

- `-e PSK`: Pre-Shared Key (PSK), if not set: "notasecret" (without quotes) by default.
- `-e USERNAME`: if not set a random username ("user[nnnn]") is created.
- `-e PASSWORD`: if not set a random weak password is created.

It only creates a single user account with the above credentials in DEFAULT hub.
See the docker log for username and password (unless `-e PASSWORD` is set), which *would look like*:

    # ========================
    # user6301
    # 2329.2890.3101.2451.9875
    # ========================
Dots (.) are part of the password. Password will not be logged if specified via `-e PASSWORD`; use `docker inspect` in case you need to see it.

Hub & server are locked down; they are given stronger random passwords which are not logged or displayed.

## OpenVPN ##

`docker run -d --cap-add NET_ADMIN -p 1194:1194/udp siomiz/softethervpn`

The entire log can be saved and used as an `.ovpn` config file (change as needed).

Server CA certificate will be created automatically at runtime if it's not set. You can supply _a self-signed 1024-bit RSA certificate/key pair_ created locally OR use the `gencert` script described below. Feed the keypair contents via `-e CERT` and `-e KEY` ([use of `--env-file`][3] is recommended). X.509 markers (like `-----BEGIN CERTIFICATE-----`) and any non-BASE64 character (incl. newline) can be omitted and will be ignored.

Examples (assuming bash; note the double-quotes `"` and backticks `` ` ``):

* ``-e CERT="`cat server.crt`" -e KEY="`cat server.key`"``
* `-e CERT="MIIDp..b9xA=" -e KEY="MIIEv..x/A=="`
* `--env-file /path/to/envlist`

`env-file` template can be generated by:

`docker run --rm siomiz/softethervpn gencert > /path/to/envlist`

where `CERT` and `KEY` already filled in. Modify `PSK`/`USERNAME`/`PASSWORD`.

Certificate volumes support (like `-v` or `--volumes-from`) will be added at some point...

## License ##

[MIT License][4].

  [1]: https://www.softether.org/
  [2]: https://github.com/SoftEtherVPN/SoftEtherVPN
  [3]: https://docs.docker.com/reference/commandline/run/
  [4]: https://github.com/siomiz/SoftEtherVPN/raw/master/LICENSE
