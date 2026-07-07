<script setup lang="ts">
const config = useRuntimeConfig();
const message = ref("Натисни кнопку, щоб перевірити backend.");
const loading = ref(false);
const error = ref("");

async function loadGreeting() {
  loading.value = true;
  error.value = "";

  try {
    const response = await $fetch<{ message: string }>(`${config.public.apiBase}/hello`);
    message.value = response.message;
  }
  catch {
    error.value = "Не вдалося отримати відповідь від backend.";
  }
  finally {
    loading.value = false;
  }
}
</script>

<template>
  <main class="min-h-screen bg-zinc-950 text-white">
    <section class="mx-auto flex min-h-screen w-full max-w-3xl flex-col items-center justify-center px-6 text-center">
      <p class="mb-3 text-sm font-medium uppercase tracking-wide text-emerald-300">
        Nuxt + Express + Docker
      </p>

      <h1 class="text-4xl font-semibold sm:text-5xl">
        Перевірка CI/CD
      </h1>

      <p class="mt-5 min-h-8 text-lg text-zinc-300">
        {{ message }}
      </p>

      <button
        class="mt-8 rounded-md bg-emerald-400 px-5 py-3 font-semibold text-zinc-950 transition hover:bg-emerald-300 disabled:cursor-not-allowed disabled:opacity-70"
        :disabled="loading"
        @click="loadGreeting"
      >
        {{ loading ? "Відправляю..." : "Отримати повідомлення - тест деплоя" }}
      </button>

      <p
        v-if="error"
        class="mt-4 text-sm text-red-300"
      >
        {{ error }}
      </p>
    </section>
  </main>
</template>
