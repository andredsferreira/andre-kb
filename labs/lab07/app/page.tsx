import { PageHeader, ResourceSection, PageFooter } from "./components/home";
import { author } from "./data/author";
import { nextJsResources, dockerResources } from "./data/resources";

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col bg-linear-to-b from-zinc-50 to-white">
      <PageHeader />
      <main className="flex-1 container mx-auto px-4 pb-16 max-w-6xl">
        <ResourceSection
          id="nextjs-resources-heading"
          heading="Next.js Resources"
          resources={nextJsResources}
          ariaLabel="Next.js resource links"
        />
        <ResourceSection
          id="docker-resources-heading"
          heading="Docker Resources"
          resources={dockerResources}
          ariaLabel="Docker resource links"
        />
        <PageFooter author={author} />
      </main>
    </div>
  );
}
