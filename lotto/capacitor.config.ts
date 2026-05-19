import type { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'com.lotto.generator',
  appName: '로또 번호 생성기',
  webDir: 'dist',
  server: {
    // 개발 시 로컬 서버 연결 (빌드 후에는 제거)
    // url: 'http://localhost:5174',
    // cleartext: true,
  },
  android: {
    buildOptions: {
      releaseType: 'APK',
    },
  },
}

export default config
