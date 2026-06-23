export default function PageHeader() {
  return (
    <header
      className="container mx-auto px-4 pt-16 pb-8 text-center"
      aria-labelledby="main-heading"
    >
      <h1
        id="main-heading"
        className="text-5xl font-bold mb-4 text-black"
      >
        Welcome to Next.js on <span className="text-blue-600">Docker</span>!
      </h1>
      <p className="text-xl text-zinc-600 max-w-2xl mx-auto">
        A production-ready example demonstrating how to Dockerize Next.js
        applications using standalone mode.
      </p>
    </header>
  );
}
