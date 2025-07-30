    <script setup>
    import { computed, ref, watch } from "vue";

    import { router, usePage } from "@inertiajs/vue3";
    import { createAppKit, useAppKit } from "@reown/appkit/vue";
    import {
        useAccount,
        useAccountEffect,
        useDisconnect,
        useSignMessage,
    } from "@wagmi/vue";
    import axios from "axios";
    import { ChevronDown, ChevronRight, Power, User } from "lucide-vue-next";
    import { avalanche, avalancheFuji, blast, linea, sepolia } from "viem/chains";

    import DangerButton from "@/Components/DangerButton.vue";
    import PrimaryButton from "@/Components/PrimaryButton.vue";
    import SecondaryButton from "@/Components/SecondaryButton.vue";
    import {
        DropdownMenu,
        DropdownMenuContent,
        DropdownMenuItem,
        DropdownMenuTrigger,
    } from "@/Components/ui/dropdown-menu";
    import { shortenAddress } from "@/lib/wagmi";
    import {
        networks,
        projectId,
        projectName,
        projectUrl,
        useWagmiAdapter
    } from "@/lib/wagmi.js";
    createAppKit({
        features: {
            email: false,
            socials: false,
        },
        adapters: [useWagmiAdapter({
            rpc: usePage().props.rpc ?? 'ankr',
            ankr: usePage().props.ankr,
            infura: usePage().props.infura,
            blast: usePage().props.blast,
            activeChains: usePage().props.activeChains,
        })],
        networks: networks.filter((n) =>
            usePage().props.activeChains.includes(n.id),
        ),
        projectId: projectId ?? usePage().props.projectId,
        metadata: {
            name: projectName,
            description: `${projectName} Crypto Memes Service`,
            url: projectUrl,
            icons: [],
        },
        themeVariables: {
            "--w3m-color-mix": "#404040",
            "--w3m-color-mix-strength": 40,
        },
        chainImages: {
            [avalanche.id]: "https://icons.llamao.fi/icons/chains/rsz_avalanche.jpg",
            [avalancheFuji.id]: "https://icons.llamao.fi/icons/chains/rsz_avalanche.jpg",
            [sepolia.id]: "https://icons.llamao.fi/icons/chains/rsz_ethereum.jpg",
            [linea.id]: "https://icons.llamao.fi/icons/chains/rsz_linea.jpg",
            [blast.id]: "https://icons.llamao.fi/icons/chains/rsz_blast.jpg",
        },
    });
    const { open: openConnectModal } = useAppKit();

    defineProps({
        size: { type: String, default: "xs" },
        full: Boolean,
        grouped: Boolean,
    });
    const authCheck = computed(() => !!usePage().props.auth.user);
    const { address, isConnected } = useAccount();

    const { disconnect } = useDisconnect();
    const { signMessageAsync } = useSignMessage();

    const handleVerify = async () => {
        try {
            // Get auth code
            const { data } = await axios.post(window.route("auth.code"));
            const authCode = data.authCode;
            // Sign message
            const signature = await signMessageAsync({
                message: authCode,
            });

            // Verify signature and login
            router.post(
                window.route("login"),
                {
                    address: address.value,
                    signature,
                },
                {
                    preserveState: true,
                    preserveScroll: true,
                },
            );
        } catch (error) {
            console.error("Verification failed:", error);
        }
    };
    const isSigningOut = ref(false);
    const signOut = async () => {
        if (isSigningOut.value) return;
        isSigningOut.value = true;
        if (authCheck.value)
            router.post(
                window.route("logout"),
                {},
                {
                    // onSuccess: () => {
                    //     router.reload();
                    // },
                    onFinish() {
                        isSigningOut.value = false;
                    },
                },
            );
    };

    const signIn = async () => {
        if (!authCheck.value) await handleVerify();
    };
    useAccountEffect({
        onConnect(data) {
            signIn();
        },
        onDisconnect() {
            signOut();
        },
    });
    watch([isConnected, authCheck], ([isConnected, authCheck]) => {
        if (isConnected && !authCheck) {
            return signIn();
        }
        if (!isConnected && authCheck) {
            return signOut();
        }
    });
</script>

<template>
    <div class="flex gap-2">
        <template v-if="$page.props.auth.user && isConnected">
            <DropdownMenu>
                <DropdownMenuTrigger>
                    <button
                        class="flex justify-center items-center gap-2 rounded-full bg-black/10 p-3 pr-3 text-white border border-white/20 w-full">
                        <img :src="$page.props.auth.user.profile_photo_url" :alt="$page.props.auth.user.name"
                            class="w-8 h-8 rounded-full" />
                        <span class="text-xs text-white">{{ shortenAddress(address) }}</span>
                        <ChevronDown class="w-4 h-4" />
                    </button>
                </DropdownMenuTrigger>
                <DropdownMenuContent class="!bg-black/10 !border-white/20 text-white">
                     <DropdownMenuItem
                        @click="$inertia.visit('/profile')"
                        class="cursor-pointer"
                        >
                        <span>Profile</span>
                    </DropdownMenuItem>
                    <DropdownMenuItem @click="signOut" class="cursor-pointer">
                        <span>Log out</span>
                    </DropdownMenuItem>
                </DropdownMenuContent>
            </DropdownMenu>
        </template>
        <!-- <template v-else-if="isConnected">
            <SecondaryButton :size="size" :class="{ 'w-full': full }" @click="handleVerify">
                Verify Signature
            </SecondaryButton>
            <DangerButton :size="size" :class="{ 'w-full': full }" @click="disconnect()">
                Disconnect
            </DangerButton>
        </template> -->
        <template v-else>
            <button :class="{ 'w-full': full }" @click="openConnectModal" 
            class="hidden md:flex items-center gap-2 border-white/20 text-white rounded-full px-5 py-4 font-medium text-sm" style="
                    background: linear-gradient(
                        to right,
                        #6c2801 0%,
                        #da5200 34%,
                        #e97c02 100%
                    );
                ">
                Log In
                <ChevronRight v-if="!grouped" class="hidden lg:block w-4 h-4" />
            </button>
            <button :class="{ 'w-full': full }" @click="openConnectModal" 
            class="md:hidden flex bg-transparent text-white font-medium text-sm hover:bg-transparent w-full !p-1">
                Log In
            </button>
        </template>
    </div>
</template>
