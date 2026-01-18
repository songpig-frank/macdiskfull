export interface Product {
    id: string;
    name: string;
    slug: string;
    description: string;
    rating: number; // 0-5
    price: string;
    pros: string[];
    cons: string[];
    affiliateLink: string;
    logo: string; // Path to logo
    isRecommended: boolean;
    features: {
        junkCleaning: boolean;
        malwareProtection: boolean;
        uninstaller: boolean;
        largeFileFinder: boolean;
        visualization: boolean;
    };
}

export const products: Product[] = [
    {
        id: 'getdiskspace',
        name: 'GetDiskSpace',
        slug: 'getdiskspace',
        description: 'The most visual and intuitive disk cleaner for macOS. Uses "SpaceSwipe" technology to quickly sort through clutter.',
        rating: 5,
        price: '$19.99',
        pros: [
            'Visual interactive file sorting',
            'Beautiful, modern interface',
            'Privacy-focused (no data collection)',
            'Affordable one-time purchase'
        ],
        cons: [
            'Newer to the market than some competitors',
            'Mac only (no Windows version)'
        ],
        affiliateLink: 'https://getdiskspace.com/buy', // This would be an affiliate link in real usage
        logo: '/images/logos/getdiskspace.png',
        isRecommended: true,
        features: {
            junkCleaning: true,
            malwareProtection: false, // Honest comparison
            uninstaller: true,
            largeFileFinder: true,
            visualization: true
        }
    },
    {
        id: 'cleanmymac',
        name: 'CleanMyMac X',
        slug: 'cleanmymac-x',
        description: 'A popular all-in-one suite for Mac maintenance. Good polish but comes with a subscription model.',
        rating: 4.5,
        price: '$39.95/yr',
        pros: [
            'Comprehensive toolset',
            'Great UI polish',
            'Includes malware removal'
        ],
        cons: [
            'Expensive subscription model',
            'Can feel bloated with unnecessary features',
            'Aggressive marketing'
        ],
        affiliateLink: 'https://macpaw.com/cleanmymac',
        logo: '/images/logos/cleanmymac.png',
        isRecommended: false,
        features: {
            junkCleaning: true,
            malwareProtection: true,
            uninstaller: true,
            largeFileFinder: true,
            visualization: false
        }
    },
    {
        id: 'daisydisk',
        name: 'DaisyDisk',
        slug: 'daisydisk',
        description: 'A visual disk analyzer that helps you see what is taking up space. Very specialized tool.',
        rating: 4.0,
        price: '$9.99',
        pros: [
            'Excellent visualization',
            'Fast scanning',
            'One-time purchase'
        ],
        cons: [
            'Limited cleaning features',
            'No uninstaller or malware tools',
            'Manual deletion only'
        ],
        affiliateLink: 'https://daisydiskapp.com',
        logo: '/images/logos/daisydisk.png',
        isRecommended: false,
        features: {
            junkCleaning: false,
            malwareProtection: false,
            uninstaller: false,
            largeFileFinder: true,
            visualization: true
        }
    },
    {
        id: 'onyx',
        name: 'OnyX',
        slug: 'onyx',
        description: 'A powerful system utility for advanced users. It is free but has a steep learning curve.',
        rating: 3.5,
        price: 'Free',
        pros: [
            'Completely free',
            'Deep system access',
            'No ads or upsells'
        ],
        cons: [
            'Complex interface',
            'Risky for beginners',
            'No visual storage analysis'
        ],
        affiliateLink: 'https://titanium-software.fr',
        logo: '/images/logos/onyx.png',
        isRecommended: false,
        features: {
            junkCleaning: true,
            malwareProtection: false,
            uninstaller: false,
            largeFileFinder: false,
            visualization: false
        }
    }
];
