import NextNProgress from "nextjs-progressbar";
import '@fontsource/poppins';
import theme from '../theme';
import type { AppProps } from 'next/app';
import Navbar from '../components/Navbar';
import { ChakraProvider } from '@chakra-ui/react';
import { Toaster, toast } from 'react-hot-toast';
import { ReactQueryDevtools } from 'react-query/devtools';
import { QueryClient, QueryClientProvider, QueryCache } from 'react-query';
import { WagmiConfig, createClient } from 'wagmi';
import { providers } from 'ethers';

// const quicknodeProvider = new providers.JsonRpcProvider(
//   "https://polygon-mumbai.g.alchemy.com/v2/UquM8WKdjXKxyu8fKcQNoVsejeoONmLe"
// );

// const client = createClient({
//   autoConnect: true,
//   provider: quicknodeProvider,
// });

import { configureChains, chain } from 'wagmi';
import { jsonRpcProvider } from 'wagmi/providers/jsonRpc';
import { alchemyProvider } from 'wagmi/providers/alchemy';
import { InjectedConnector } from 'wagmi/connectors/injected';

const { chains, provider } = configureChains(
  [chain.polygonMumbai],
  [
    jsonRpcProvider({
      priority: 0,
      rpc: (chain) => ({
        http: '',
      }),
    }),
    alchemyProvider({ alchemyId: 'https://polygon-mumbai.g.alchemy.com/v2/UquM8WKdjXKxyu8fKcQNoVsejeoONmLe', priority: 1 }),
  ]
);

// Give wagmi our provider config and allow it to autoconnect wallet
const client = createClient({
  autoConnect: true,
  connectors: [new InjectedConnector({ chains })],
  provider: provider,
});


// // Use wagmi to configure the provider.
// // Right now, we will only connect to hardhat's standalone localhost network
// const localhostProvider = new providers.JsonRpcProvider(
//   'http://localhost:8545', 
//   {name: 'dev', chainId: 1337, ensAddress: undefined}
// );
// // Give wagmi our provider config and allow it to autoconnect wallet
// const client = createClient({
// 	autoConnect: true,
//   provider: localhostProvider
// });

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
    },
  },
  queryCache: new QueryCache({
    onError: () => {
      toast.error(
        'Network Error: Ensure Metamask is connected & on the same network that your contract is deployed to.'
      );
    },
  }),
});

function MyApp({ Component, pageProps }: AppProps) {
  return (
	// Provide the WagmiConfig at the top-level of our app
    <WagmiConfig client={client}>
      <ChakraProvider theme={theme}>
        <QueryClientProvider client={queryClient}>
        <NextNProgress color='#553C9A' />
          <Navbar />
          <Component {...pageProps} />
          <Toaster position='bottom-right' />
          <ReactQueryDevtools initialIsOpen={false} />
        </QueryClientProvider>
      </ChakraProvider>
    </WagmiConfig>
  );
}

export default MyApp;