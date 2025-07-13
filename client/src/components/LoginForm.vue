<script setup lang="ts">
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import IconGoogle from '@/components/icons/IconGoogle.vue'
import { GoogleLogin } from 'vue3-google-login'

const emit = defineEmits(['onLoginSuccess'])
</script>

<template>
  <div class="flex flex-col gap-6">
    <Card>
      <CardHeader class="text-center">
        <CardTitle class="text-xl"> Welcome back </CardTitle>
        <CardDescription> Login with your Google account </CardDescription>
      </CardHeader>
      <CardContent>
        <div class="grid gap-6">
          <div class="flex flex-col gap-4">
            <GoogleLogin :callback="(data: any) => emit('onLoginSuccess', data)" popupType="CODE">
              <Button variant="outline" class="w-full">
                <IconGoogle />
                Login with Google
              </Button>
            </GoogleLogin>
          </div>
        </div>
      </CardContent>
    </Card>
  </div>
</template>
