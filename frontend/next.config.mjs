/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000', // 環境変数が設定されていない場合のデフォルト値も設定
  },
};

export default nextConfig;
