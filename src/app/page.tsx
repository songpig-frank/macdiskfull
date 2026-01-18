import Image from "next/image";
import Navbar from '@/components/Navbar';
import Hero from '@/components/Hero';
import ComparisonTable from '@/components/ComparisonTable';
import Footer from '@/components/Footer';

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col">
      <Navbar />

      <main className="flex-grow">
        <Hero />

        <section id="comparison" className="py-12 sm:py-20 relative">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-3xl sm:text-5xl font-bold mb-6">Top Rated Mac Cleaners</h2>
              <p className="text-gray-400 max-w-2xl mx-auto text-lg">
                We've analyzed the most popular disk cleaning utilities for checking features, ease of use, and price.
                Here is how they stack up.
              </p>
            </div>

            <ComparisonTable />
          </div>
        </section>

        <section className="py-20 bg-white/[0.02]">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="prose prose-invert prose-lg max-w-none">
              <h2 className="text-3xl font-bold text-center mb-12">Why You Need a Disk Cleaner for Mac</h2>

              <div className="grid gap-12">
                <div>
                  <h3 className="text-2xl font-bold mb-4 text-purple-400">1. System Junk Accumulates</h3>
                  <p className="text-gray-300">
                    Even though macOS is efficient, it accumulates cache files, logs, and temporary data over time.
                    These can take up gigabytes of space without you realizing it. A good cleaner identifies and removes these safely.
                  </p>
                </div>

                <div>
                  <h3 className="text-2xl font-bold mb-4 text-purple-400">2. "System Data" Bloat</h3>
                  <p className="text-gray-300">
                    Have you ever looked at your storage and seen a massive gray bar labeled "System Data"?
                    This is often a mix of local Time Machine snapshots, outdated iOS backups, and application caches.
                    Manual removal is risky, but tools like <strong>GetDiskSpace</strong> can visualize exactly what this is.
                  </p>
                </div>

                <div>
                  <h3 className="text-2xl font-bold mb-4 text-purple-400">3. Performance Optimization</h3>
                  <p className="text-gray-300">
                    A nearly full hard drive significantly slows down your Mac because the system struggles to find swap space.
                    Keeping at least 15-20% of your disk free is crucial for optimal performance, especially on Apple Silicon Macs.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}
