# DNS with the dig command

Use the +short option for a concise answer

```bash
dig example.com +short
```
## Query only the answer (A record)

- +noall : removes all the detailed output.
- +answer : adds only the answer to the output.

```bash
dig example.com +noall +answer
```

## Trace the full query route

Can be combined with +noall for a simpler output

```bash
dig example.com +trace
dig example.com +trace +noall
```

## Querying a specific name server

By default the dig uses the servers listed in /etc/resolv.conf

```bash
# google dns server
dig example.com @8.8.8.8
```

## Specifying record type

By default dig queries A records if nothing is specified.

In general:

```bash
dig example.com [recordtype]
```
### Querying all records

```bash
dig cisco.com any 
```
Here is a big query example with trace aswell

```bash
dig digitalocean.com any +trace
```
## Reverse DNS lookup

Use the -x option.

```bash
dig -x 104.16.132.229
```