## Frontend Applications

**Frontend App**: A frontend app is ultimately just static files: HTML, CSS,
JavaScript and assets (images, fonts, videos, etc). The way a frontend app gets
served to the browsers can vary depending on the type of frontend and the
overall architecture. What happens is that the browser pretty much just
downloads those static files to your local machine and runs them (the browser
understands HTML, CSS, Javascript).

Two questions define every frontend architecture:

1. Where and when is the HTML produced?
2. What service hands the files to the browser?

### Types of Frontends

| Type                                   | Description                                                                                                                                                                                                                                |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Single Page Application (SPA)          | SPAs are heavilly javascripted applications. The browser usually reads a single index.html file that contains a big JavaScript bundle. The JavaScript app then runs entirely on the browser routing requests to a backend API for example. |
| Server Side Rendered Application (SSR) | SSRs are greate for SEO apps. The HTML is rendered and served by a server to the browser, usually with minimal javascript.                                                                                                                 |
| Static Sites (SSG)                     | Completly static files HTML are served to the browser which reads them.                                                                                                                                                                    |

## Architectures

### SPA + Separate API

This example architecture demonstrates two separate applications deployed as two
separate artifacts. The SPA or frontend is served by some web servers behind a
load balancer and typically written with frameworks like React, Angular, Vue,
etc. The backend API is called by the SPA itself to seperate servers behind a
load balancer. The backend is usually written with frameworks like
Spring/SpringBoot (Java), Go, FastAPI (Python).

The purple lines represent the first request the client/browser makes to get the
frontend app (SPA). The blue lines are made from the already builded SPA to the
backend API.

![SPA + Separate API](web-arch-01.png)

![SPA + Separate API](web-arch-02.png)

