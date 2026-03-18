import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      // 将所有 /api 开头的请求代理到服务器
      '/api': {
        target: 'http://127.0.0.1:3000', // 请根据实际情况修改 IP 地址
        changeOrigin: true,
        // 如果后端接口本身不包含 /api 前缀，可以开启下面的重写规则
        // rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})
