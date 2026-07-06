export default defineNuxtConfig({
  compatibilityDate: "2024-08-01",
  modules: ["@nuxtjs/tailwindcss"],
  css: ["~/assets/css/main.css"],
  runtimeConfig: {
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_BASE || "/api"
    }
  }
});
