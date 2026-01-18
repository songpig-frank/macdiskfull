import Link from 'next/link';
import { HardDrive } from 'lucide-react';

export default function Footer() {
    return (
        <footer className="border-t border-[var(--border-glass)] bg-[var(--bg-main)]/50 backdrop-blur-xl pt-16 pb-8">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-12 mb-12">
                    <div className="md:col-span-2">
                        <Link href="/" className="flex items-center gap-2 mb-4 group">
                            <div className="p-2 bg-gradient-to-br from-purple-600 to-pink-600 rounded-lg">
                                <HardDrive className="h-5 w-5 text-white" />
                            </div>
                            <span className="font-bold text-xl tracking-tight text-white">
                                MacDiskFull<span className="text-purple-500">.com</span>
                            </span>
                        </Link>
                        <p className="text-gray-400 max-w-sm leading-relaxed">
                            We test and review Mac software to help you keep your computer running like new.
                            Our recommendations are based on real-world usage and rigorous testing.
                        </p>
                    </div>

                    <div>
                        <h4 className="font-bold text-white mb-4">Site Links</h4>
                        <ul className="space-y-3 text-gray-400 text-sm">
                            <li><Link href="/" className="hover:text-purple-400 transition-colors">Home</Link></li>
                            <li><Link href="/comparisons" className="hover:text-purple-400 transition-colors">Comparisons</Link></li>
                            <li><Link href="/blog" className="hover:text-purple-400 transition-colors">Blog</Link></li>
                            <li><Link href="/about" className="hover:text-purple-400 transition-colors">About Us</Link></li>
                        </ul>
                    </div>

                    <div>
                        <h4 className="font-bold text-white mb-4">Legal</h4>
                        <ul className="space-y-3 text-gray-400 text-sm">
                            <li><Link href="/privacy" className="hover:text-purple-400 transition-colors">Privacy Policy</Link></li>
                            <li><Link href="/terms" className="hover:text-purple-400 transition-colors">Terms of Service</Link></li>
                            <li><Link href="/affiliate-disclosure" className="hover:text-purple-400 transition-colors">Affiliate Disclosure</Link></li>
                        </ul>
                    </div>
                </div>

                <div className="pt-8 border-t border-[var(--border-glass)] text-center text-gray-500 text-xs">
                    <p className="mb-2">© 2026 MacDiskFull.com. All rights reserved.</p>
                    <p>
                        Disclaimer: We are supported by our readers. When you buy through links on our site, we may earn an affiliate commission.
                        However, this does not affect our detailed reviews and comparisons.
                    </p>
                </div>
            </div>
        </footer>
    );
}
