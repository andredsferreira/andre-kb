import type { ResourceLink } from "../../data/resources";
import ResourceCard from "./ResourceCard";

interface ResourceSectionProps {
  id: string;
  heading: string;
  resources: ResourceLink[];
  ariaLabel: string;
}

export default function ResourceSection({
  id,
  heading,
  resources,
  ariaLabel,
}: ResourceSectionProps) {
  return (
    <section
      className="mb-12 last:mb-16"
      aria-labelledby={id}
    >
      <h2
        id={id}
        className="text-2xl font-semibold mb-6 text-black text-center"
      >
        {heading}
      </h2>
      <nav
        className="grid md:grid-cols-2 lg:grid-cols-4 gap-6"
        aria-label={ariaLabel}
      >
        {resources.map((resource) => (
          <ResourceCard key={resource.href} resource={resource} />
        ))}
      </nav>
    </section>
  );
}
