import { Check, X, Star, Download, ExternalLink } from 'lucide-react';
import { products } from '@/data/products';
import Link from 'next/link';

export default function ComparisonTable() {
    // Sort products to ensure GetDiskSpace is first (it is already, but good to be safe if I change order later)
    const sortedProducts = [...products].sort((a, b) => (a.isRecommended ? -1 : 1));

    const featuresList = [
        { key: 'junkCleaning', label: 'Junk Cleaning' },
        { key: 'largeFileFinder', label: 'Large File Finder' },
        { key: 'visualization', label: 'Visual Storage Analysis' },
        { key: 'uninstaller', label: 'App Uninstaller' },
        { key: 'malwareProtection', label: 'Malware Protection' },
    ] as const;

    return (
        <div className="w-full overflow-hidden rounded-3xl border border-[var(--border-glass)] bg-[var(--bg-card)] backdrop-blur-sm shadow-2xl shadow-purple-900/10">
            <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr>
                            <th className="p-6 min-w-[200px] bg-transparent sticky left-0 z-10"></th>
                            {sortedProducts.map((product) => (
                                <th
                                    key={product.id}
                                    className={`p-6 min-w-[220px] text-center align-bottom relative ${product.isRecommended ? 'bg-purple-900/10 border-t-4 border-purple-500 rounded-t-lg' : ''
                                        }`}
                                >
                                    {product.isRecommended && (
                                        <div className="absolute top-0 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-purple-500 text-white text-xs font-bold px-3 py-1 rounded-full shadow-lg shadow-purple-500/50">
                                            BEST CHOICE
                                        </div>
                                    )}
                                    <div className="flex flex-col items-center gap-4">
                                        {/* Placeholder for Logo if image not available, otherwise img */}
                                        <div className={`w-16 h-16 rounded-2xl flex items-center justify-center text-xl font-bold mb-2 shadow-lg ${product.isRecommended
                                                ? 'bg-gradient-to-br from-purple-500 to-pink-500 text-white'
                                                : 'bg-white/5 text-gray-400 border border-white/10'
                                            }`}>
                                            {product.name.charAt(0)}
                                        </div>
                                        <div className="space-y-1">
                                            <h3 className={`text-lg font-bold ${product.isRecommended ? 'text-white' : 'text-gray-300'}`}>
                                                {product.name}
                                            </h3>
                                            <div className="flex items-center justify-center gap-1 text-yellow-400">
                                                {Array.from({ length: 5 }).map((_, i) => (
                                                    <Star
                                                        key={i}
                                                        size={14}
                                                        fill={i < Math.floor(product.rating) ? "currentColor" : "none"}
                                                        className={i < Math.floor(product.rating) ? "" : "text-gray-600"}
                                                    />
                                                ))}
                                                <span className="text-xs text-gray-400 ml-1">{product.rating}</span>
                                            </div>
                                        </div>
                                    </div>
                                </th>
                            ))}
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-[var(--border-glass)]">

                        {/* Price Row */}
                        <tr className="hover:bg-white/5 transition-colors">
                            <td className="p-6 font-semibold text-gray-300 sticky left-0 z-10 bg-[var(--bg-main)]/90 backdrop-blur-md border-r border-[var(--border-glass)]">
                                Price
                            </td>
                            {sortedProducts.map((product) => (
                                <td key={product.id} className={`p-6 text-center text-lg ${product.isRecommended ? 'font-bold text-white bg-purple-900/5' : 'text-gray-400'}`}>
                                    {product.price}
                                </td>
                            ))}
                        </tr>

                        {/* Features Rows */}
                        {featuresList.map((feature) => (
                            <tr key={feature.key} className="hover:bg-white/5 transition-colors group">
                                <td className="p-6 font-medium text-gray-400 sticky left-0 z-10 bg-[var(--bg-main)]/90 backdrop-blur-md border-r border-[var(--border-glass)] group-hover:text-white transition-colors">
                                    {feature.label}
                                </td>
                                {sortedProducts.map((product) => (
                                    <td key={product.id} className={`p-6 text-center ${product.isRecommended ? 'bg-purple-900/5' : ''}`}>
                                        <div className="flex justify-center">
                                            {product.features[feature.key] ? (
                                                <div className="w-8 h-8 rounded-full bg-green-500/20 flex items-center justify-center text-green-400">
                                                    <Check size={18} strokeWidth={3} />
                                                </div>
                                            ) : (
                                                <div className="w-8 h-8 rounded-full bg-red-500/10 flex items-center justify-center text-red-400/50">
                                                    <X size={18} strokeWidth={3} />
                                                </div>
                                            )}
                                        </div>
                                    </td>
                                ))}
                            </tr>
                        ))}

                        {/* CTA Row */}
                        <tr>
                            <td className="p-6 sticky left-0 z-10 bg-transparent"></td>
                            {sortedProducts.map((product) => (
                                <td key={product.id} className={`p-6 text-center ${product.isRecommended ? 'bg-purple-900/5 pb-8' : 'pb-8'}`}>
                                    <Link
                                        href={product.affiliateLink}
                                        target="_blank"
                                        className={`inline-flex items-center gap-2 px-6 py-3 rounded-full font-bold transition-all transform hover:scale-105 ${product.isRecommended
                                                ? 'bg-white text-purple-900 hover:bg-gray-100 shadow-xl shadow-purple-900/20'
                                                : 'bg-white/5 text-gray-300 hover:bg-white/10 border border-white/10'
                                            }`}
                                    >
                                        {product.isRecommended ? (
                                            <>
                                                <Download size={18} />
                                                Download Now
                                            </>
                                        ) : (
                                            <>
                                                Visit Site
                                                <ExternalLink size={16} />
                                            </>
                                        )}
                                    </Link>
                                </td>
                            ))}
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    );
}
