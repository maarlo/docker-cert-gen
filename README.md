# Docker: Self Signed Certificate Generator

## Build

```bash
docker build -t cert-gen .
```

## Usage

```bash
docker run --rm -v ${PWD}/certs:/certs -e DOMAIN="example.com" cert-gen
```

- Volumes:
  - Certificates are stored at ``/certs`` folder inside the container.
- Environment
  - DOMAIN: The domain name for the certificate
  - SUBJ_C: *Optional*. The C subject for the certificate.
  - SUBJ_ST: *Optional*. The ST subject for the certificate.
  - SUBJ_L: *Optional*. The L subject for the certificate.
  - SUBJ_O: *Optional*. The O subject for the certificate.
  - SUBJ_OU: *Optional*. The OU subject for the certificate.

## Debug

```bash
docker run --rm -it cert-gen bash
```

## Thanks

The ideas are from:
- [https://devopscube.com/create-self-signed-certificates-openssl/](https://devopscube.com/create-self-signed-certificates-openssl/)