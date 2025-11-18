# AWS CloudFront

Cloudfront is a global service that is based on the AWS's CDN. It allows fast
delivery of content based on caching rules. 

When used it's usually the first thing client's requests reach. For that reason
it works very well with Route 53 allowing records to have a cloudfront
distribution as an endpoint.

*Cloudfront distribution*: A resource that describes what type of content you
will deliver, how you will cache it, and the endpoints for it.

## CloudFront cache behaviors

*Default cache behavior*: This is the default cache behavior for the
distribution.

*Ordered cache behavior*: Allows for fine grained control of cache behavior
based on specific URLs