/* eslint-disable import/order */
import { WagmiAdapter } from '@reown/appkit-adapter-wagmi';

import {
    arbitrum,
    arbitrumGoerli,
    arbitrumNova,
    arbitrumSepolia,
    avalanche,
    avalancheFuji,
    base,
    baseGoerli,
    baseSepolia,
    blast,
    blastSepolia,
    bsc,
    bscTestnet,
    celo,
    celoAlfajores,
    fantom,
    fantomTestnet,
    gnosis,
    goerli,
    holesky,
    linea,
    lineaGoerli,
    lineaSepolia,
    mainnet,
    mantle,
    mantleSepoliaTestnet,
    mode,
    moonbeam,
    moonriver,
    opBNB,
    opBNBTestnet,
    optimism,
    optimismGoerli,
    optimismSepolia,
    palm,
    palmTestnet,
    polygon,
    polygonAmoy,
    polygonMumbai,
    scroll,
    scrollSepolia,
    sepolia,
    unichainSepolia,
    zetachain,
    zkLinkNovaSepoliaTestnet,
    zksync,
    zksyncSepoliaTestnet,
} from '@reown/appkit/networks';
import { http } from '@wagmi/vue';
import { fallback } from 'viem';
export const networks = [avalanche, avalancheFuji, sepolia, arbitrum, bsc, linea, base, blast];
export const projectId = import.meta.env.VITE_PROJECT_ID;
export const projectUrl = import.meta.env.VITE_PROJECT_URL;
export const projectName = import.meta.env.VITE_PROJECT_APP_NAME;
export const ankrTransports = (ANKR_KEY) => ({
    // Ethereum and testnets
    [mainnet.id]: `https://rpc.ankr.com/eth/${ANKR_KEY}`,
    [sepolia.id]: `https://rpc.ankr.com/eth_sepolia/${ANKR_KEY}`,
    [goerli.id]: `https://rpc.ankr.com/eth_goerli/${ANKR_KEY}`,

    // BNB Smart Chain
    [bsc.id]: `https://rpc.ankr.com/bsc/${ANKR_KEY}`,
    [bscTestnet.id]: `https://rpc.ankr.com/bsc_testnet/${ANKR_KEY}`,

    // Polygon
    [polygon.id]: `https://rpc.ankr.com/polygon/${ANKR_KEY}`,
    [polygonMumbai.id]: `https://rpc.ankr.com/polygon_mumbai/${ANKR_KEY}`,

    // Optimism
    [optimism.id]: `https://rpc.ankr.com/optimism/${ANKR_KEY}`,
    [optimismGoerli.id]: `https://rpc.ankr.com/optimism_testnet/${ANKR_KEY}`,

    // Arbitrum
    [arbitrum.id]: `https://rpc.ankr.com/arbitrum/${ANKR_KEY}`,
    [arbitrumGoerli.id]: `https://rpc.ankr.com/arbitrum_goerli/${ANKR_KEY}`,

    // Avalanche
    [avalanche.id]: `https://rpc.ankr.com/avalanche/${ANKR_KEY}`,
    [avalancheFuji.id]: `https://rpc.ankr.com/avalanche_fuji/${ANKR_KEY}`,

    // Fantom
    [fantom.id]: `https://rpc.ankr.com/fantom/${ANKR_KEY}`,
    [fantomTestnet.id]: `https://rpc.ankr.com/fantom_testnet/${ANKR_KEY}`,

    // Gnosis (xDai)
    [gnosis.id]: `https://rpc.ankr.com/gnosis/${ANKR_KEY}`,

    // Base
    [base.id]: `https://rpc.ankr.com/base/${ANKR_KEY}`,
    [baseGoerli.id]: `https://rpc.ankr.com/base_goerli/${ANKR_KEY}`,

    // zkSync
    [zksync.id]: `https://rpc.ankr.com/zksync_era/${ANKR_KEY}`,

    // Celo
    [celo.id]: `https://rpc.ankr.com/celo/${ANKR_KEY}`,

    // Moonbeam ecosystem
    [moonbeam.id]: `https://rpc.ankr.com/moonbeam/${ANKR_KEY}`,
    [moonriver.id]: `https://rpc.ankr.com/moonriver/${ANKR_KEY}`
});

export const infuraTransports = (INFURA_KEY) => ({
    // Ethereum and testnets
    [mainnet.id]: `https://mainnet.infura.io/v3/${INFURA_KEY}`,
    [sepolia.id]: `https://sepolia.infura.io/v3/${INFURA_KEY}`,
    [holesky.id]: `https://holesky.infura.io/v3/${INFURA_KEY}`,

    // Layer 2 Networks
    // Arbitrum
    [arbitrum.id]: `https://arbitrum-mainnet.infura.io/v3/${INFURA_KEY}`,
    [arbitrumSepolia.id]: `https://arbitrum-sepolia.infura.io/v3/${INFURA_KEY}`,

    // Optimism
    [optimism.id]: `https://optimism-mainnet.infura.io/v3/${INFURA_KEY}`,
    [optimismSepolia.id]: `https://optimism-sepolia.infura.io/v3/${INFURA_KEY}`,

    // Base
    [base.id]: `https://base-mainnet.infura.io/v3/${INFURA_KEY}`,
    [baseSepolia.id]: `https://base-sepolia.infura.io/v3/${INFURA_KEY}`,

    // Linea
    [linea.id]: `https://linea-mainnet.infura.io/v3/${INFURA_KEY}`,
    [lineaSepolia.id]: `https://linea-sepolia.infura.io/v3/${INFURA_KEY}`,

    // ZKSync Era
    [zksync.id]: `https://zksync-mainnet.infura.io/v3/${INFURA_KEY}`,
    [zkLinkNovaSepoliaTestnet.id]: `https://zksync-sepolia.infura.io/v3/${INFURA_KEY}`,

    // Other EVM Networks
    // Avalanche
    [avalanche.id]: `https://avalanche-mainnet.infura.io/v3/${INFURA_KEY}`,
    [avalancheFuji.id]: `https://avalanche-fuji.infura.io/v3/${INFURA_KEY}`,

    // BSC
    [bsc.id]: `https://bsc-mainnet.infura.io/v3/${INFURA_KEY}`,
    [bscTestnet.id]: `https://bsc-testnet.infura.io/v3/${INFURA_KEY}`,

    // Polygon
    [polygon.id]: `https://polygon-mainnet.infura.io/v3/${INFURA_KEY}`,
    [polygonAmoy.id]: `https://polygon-amoy.infura.io/v3/${INFURA_KEY}`,

    // Celo
    [celo.id]: `https://celo-mainnet.infura.io/v3/${INFURA_KEY}`,
    [celoAlfajores.id]: `https://celo-alfajores.infura.io/v3/${INFURA_KEY}`,

    // Palm
    [palm.id]: `https://palm-mainnet.infura.io/v3/${INFURA_KEY}`,
    [palmTestnet.id]: `https://palm-testnet.infura.io/v3/${INFURA_KEY}`,

    // Additional Networks
    // Blast
    [blast.id]: `https://blast-mainnet.infura.io/v3/${INFURA_KEY}`,
    [blastSepolia.id]: `https://blast-sepolia.infura.io/v3/${INFURA_KEY}`,

    // Mantle
    [mantle.id]: `https://mantle-mainnet.infura.io/v3/${INFURA_KEY}`,
    [mantleSepoliaTestnet.id]: `https://mantle-sepolia.infura.io/v3/${INFURA_KEY}`,

    // opBNB
    [opBNB.id]: `https://opbnb-mainnet.infura.io/v3/${INFURA_KEY}`,
    [opBNBTestnet.id]: `https://opbnb-testnet.infura.io/v3/${INFURA_KEY}`,

    // Scroll
    [scroll.id]: `https://scroll-mainnet.infura.io/v3/${INFURA_KEY}`,
    [scrollSepolia.id]: `https://scroll-sepolia.infura.io/v3/${INFURA_KEY}`,


    // Unichain
    [unichainSepolia.id]: `https://unichain-sepolia.infura.io/v3/${INFURA_KEY}`
});

export const blastapiTransports = (BLAST_KEY) => ({
    // Ethereum and testnets
    [mainnet.id]: `https://eth-mainnet.blastapi.io/${BLAST_KEY}`,
    [sepolia.id]: `https://eth-sepolia.blastapi.io/${BLAST_KEY}`,
    [goerli.id]: `https://eth-goerli.blastapi.io/${BLAST_KEY}`,
    [holesky.id]: `https://eth-holesky.blastapi.io/${BLAST_KEY}`,

    // Layer 2s and Scaling Solutions
    // Arbitrum
    [arbitrum.id]: `https://arbitrum-one.blastapi.io/${BLAST_KEY}`,
    [arbitrumNova.id]: `https://arbitrum-nova.blastapi.io/${BLAST_KEY}`,
    [arbitrumGoerli.id]: `https://arbitrum-goerli.blastapi.io/${BLAST_KEY}`,
    [arbitrumSepolia.id]: `https://arbitrum-sepolia.blastapi.io/${BLAST_KEY}`,

    // Base
    [base.id]: `https://base-mainnet.blastapi.io/${BLAST_KEY}`,
    [baseGoerli.id]: `https://base-goerli.blastapi.io/${BLAST_KEY}`,

    // Linea
    [linea.id]: `https://linea-mainnet.blastapi.io/${BLAST_KEY}`,
    [lineaGoerli.id]: `https://linea-goerli.blastapi.io/${BLAST_KEY}`,

    // Scroll
    [scroll.id]: `https://scroll-mainnet.blastapi.io/${BLAST_KEY}`,
    [scrollSepolia.id]: `https://scroll-sepolia.blastapi.io/${BLAST_KEY}`,

    // zkSync
    [zksync.id]: `https://zksync-mainnet.blastapi.io/${BLAST_KEY}`,
    [zksyncSepoliaTestnet.id]: `https://zksync-sepolia.blastapi.io/${BLAST_KEY}`,

    // Other EVM Networks
    // BSC
    [bsc.id]: `https://bsc-mainnet.blastapi.io/${BLAST_KEY}`,
    [bscTestnet.id]: `https://bsc-testnet.blastapi.io/${BLAST_KEY}`,

    // Polygon
    [polygon.id]: `https://polygon-mainnet.blastapi.io/${BLAST_KEY}`,
    [polygonAmoy.id]: `https://polygon-amoy.blastapi.io/${BLAST_KEY}`,

    // Gnosis
    [gnosis.id]: `https://gnosis-mainnet.blastapi.io/${BLAST_KEY}`,

    // Fantom
    [fantom.id]: `https://fantom-mainnet.blastapi.io/${BLAST_KEY}`,
    [fantomTestnet.id]: `https://fantom-testnet.blastapi.io/${BLAST_KEY}`,

    // Blast L2
    [blast.id]: `https://blastl2-mainnet.blastapi.io/${BLAST_KEY}`,
    [blastSepolia.id]: `https://blastl2-sepolia.blastapi.io/${BLAST_KEY}`,

    // Mode
    [mode.id]: `https://mode-mainnet.blastapi.io/${BLAST_KEY}`,

    // ZetaChain
    [zetachain.id]: `https://zetachain-mainnet.blastapi.io/${BLAST_KEY}`,

    // Avalanche & Avalanche Fuji Testnet
    [avalanche.id]: `https://ava-mainnet.blastapi.io/${BLAST_KEY}`,
    [avalancheFuji.id]: `https://ava-testnet.blastapi.io/${BLAST_KEY}`,
});


function getTransportUrls(chainId, rpcConfig) {
    const { ankr, infura, blast } = rpcConfig;
    const urls = [];
    // Add additional transport URLs from different providers based on configuration
    if (ankr && ankrTransports(ankr)[chainId]) {
        urls.push(ankrTransports(ankr)[chainId]);
    }
    if (infura && infuraTransports(infura)[chainId]) {
        urls.push(infuraTransports(infura)[chainId]);
    }
    if (blast && blastapiTransports(blast)[chainId]) {
        urls.push(blastapiTransports(blast)[chainId]);
    }
    return [...new Set(urls)]; // Remove duplicates
}

export const useWagmiAdapter = ({
    rpc = 'ankr', // default RPC provider: 'ankr', 'infura', or 'blast'
    ankr = null, // ankrApiKey
    infura, // infuraApiKey
    blast, // blastApiKey
    activeChains = [],
}) => {
    // Create transports object for WagmiAdapter
    console.log(ankr, infura, blast);
    const transports = activeChains.reduce((acc, chainId) => {
        const transportUrls = getTransportUrls(chainId, { ankr, infura, blast });
        // Skip if the chain isn't supported by the selected provider
        console.log(chainId);
        if (!transportUrls.length) {
            console.warn(`Chain ID ${chainId} not supported by ${rpc} provider`);
            return acc;
        }
        const transports = transportUrls.map(url => http(url));
        return {
            ...acc,
            [chainId]: fallback(transports, {
                rank: true,
                retryCount: 2,
                timeout: 10000
            })
        };
    }, {});

    activeChains.push(43114);

    console.log(activeChains);
    console.log(networks.filter(n => activeChains.includes(n?.id)));

    // Create and return the WagmiAdapter instance
    return new WagmiAdapter({
        networks: networks.filter(n => activeChains.includes(n?.id)),
        multiInjectedProviderDiscovery: true,
        autoConnect: true,
        transports,
    });
};


export function shortenAddress(address, chars = 4) {
    if (!address) return null;
    if (address?.length <= chars) return address;
    return `${address.substring(0, chars + 2)}...${address.substring(
        42 - chars,
    )}`;
}
// shorten the checksummed version of the input address to have 0x + 4 characters at start and end

export function truncateTx(fullStr = "", strLen = 33, separator = "...") {
    if (fullStr?.length <= strLen) return fullStr;
    const sepLen = separator.length;
    const charsToShow = strLen - sepLen;
    const frontChars = Math.ceil(charsToShow / 2);
    const backChars = Math.floor(charsToShow / 2);
    return (
        fullStr.substring(0, frontChars + 3) +
        separator +
        fullStr.substring(fullStr.length - backChars - 3)
    );
}
