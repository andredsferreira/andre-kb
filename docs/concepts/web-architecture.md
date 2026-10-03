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

## Example Architectures

### SPA + Seperate API


