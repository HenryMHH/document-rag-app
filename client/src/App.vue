<script setup lang="ts">
import { RouterView } from 'vue-router'
import { useInitAuth } from './hooks/useInitAuth'
import { DotLottieVue } from '@lottiefiles/dotlottie-vue'
import flowLoadingUrl from '@/assets/lottie/flow-loading.lottie?url'
import { Toaster } from '@/components/ui/sonner'
import 'vue-sonner/style.css'

const { isInitialized } = useInitAuth()
</script>

<template>
  <div class="flex justify-center items-center h-screen" v-if="!isInitialized">
    <DotLottieVue style="width: 200px; height: 200px" autoplay loop :src="flowLoadingUrl" />
  </div>
  <RouterView v-else />
  <Toaster />
</template>
