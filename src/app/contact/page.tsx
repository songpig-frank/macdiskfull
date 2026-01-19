import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import { Mail, LifeBuoy, ExternalLink } from 'lucide-react';
import Link from 'next/link';

export default function Contact() {
    return (
        <div className="min-h-screen flex flex-col bg-black text-white selection:bg-purple-500/30">
            <Navbar />

            <main className="flex-grow pt-32 pb-20">
                <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">

                    {/* Header */}
                    <div className="text-center mb-16">
                        <h1 className="text-4xl sm:text-5xl font-bold mb-6 bg-clip-text text-transparent bg-gradient-to-r from-white to-gray-400">
                            Get in Touch
                        </h1>
                        <p className="text-xl text-gray-400 max-w-2xl mx-auto">
                            We'd love to hear your feedback on our reviews, comparisons, and guides.
                        </p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8">

                        {/* 1. Editorial Inquiries */}
                        <div className="p-8 rounded-2xl glass-panel border border-[var(--border-glass)] bg-white/5 hover:bg-white/10 transition-colors">
                            <div className="bg-purple-600/20 p-3 rounded-xl w-fit mb-6">
                                <Mail className="h-8 w-8 text-purple-400" />
                            </div>
                            <h2 className="text-2xl font-bold mb-4">Editorial Team</h2>
                            <p className="text-gray-400 mb-6 leading-relaxed">
                                Have a tip, spotted a correction, or want to suggest a piece of software for us to review? We are always looking to improve our content.
                            </p>
                            <a
                                href="mailto:editor@macdiskfull.com"
                                className="inline-flex items-center text-purple-400 font-semibold hover:text-purple-300 transition-colors"
                            >
                                editor@macdiskfull.com <ExternalLink className="ml-2 h-4 w-4" />
                            </a>
                        </div>

                        {/* 2. Product Support (The "Explicit but Nice" part) */}
                        <div className="p-8 rounded-2xl glass-panel border border-[var(--border-glass)] bg-white/5 hover:bg-white/10 transition-colors">
                            <div className="bg-blue-600/20 p-3 rounded-xl w-fit mb-6">
                                <LifeBuoy className="h-8 w-8 text-blue-400" />
                            </div>
                            <h2 className="text-2xl font-bold mb-4">Product Support</h2>
                            <p className="text-gray-400 mb-6 leading-relaxed">
                                Need technical help with a product? As an independent review site, we don't manage licenses or support for the software we recommend.
                            </p>
                            <p className="text-sm font-medium text-gray-300 mb-3">Please contact the developers directly:</p>

                            <ul className="space-y-3">
                                <li>
                                    <Link
                                        href="https://getdiskspace.com/support"
                                        target="_blank"
                                        className="flex items-center justify-between p-3 rounded-lg bg-white/5 hover:bg-white/10 transition-all border border-transparent hover:border-purple-500/30 group"
                                    >
                                        <span className="font-medium group-hover:text-purple-300">GetDiskSpace Support</span>
                                        <ExternalLink className="h-4 w-4 text-gray-500 group-hover:text-purple-400" />
                                    </Link>
                                </li>
                                <li>
                                    <Link
                                        href="https://macpaw.com/support/cleanmymac"
                                        target="_blank"
                                        className="flex items-center justify-between p-3 rounded-lg bg-white/5 hover:bg-white/10 transition-all border border-transparent hover:border-blue-500/30 group"
                                    >
                                        <span className="font-medium group-hover:text-blue-300">CleanMyMac X Support</span>
                                        <ExternalLink className="h-4 w-4 text-gray-500 group-hover:text-blue-400" />
                                    </Link>
                                </li>
                            </ul>
                        </div>

                    </div>

                    {/* FAQ / Bottom Note */}
                    <div className="mt-16 text-center pt-10 border-t border-[var(--border-glass)]">
                        <p className="text-gray-500 text-sm">
                            For business, advertising, or partnership inquiries, please email <a href="mailto:partnerships@macdiskfull.com" className="text-gray-400 hover:text-white transition-colors">partnerships@macdiskfull.com</a>.
                        </p>
                    </div>

                </div>
            </main>

            <Footer />
        </div>
    );
}
