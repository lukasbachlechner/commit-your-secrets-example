// Stands in for your actual app: it just proves the values arrived.
const mask = (v) => (v ? v.slice(0, 8) + '…' : '(missing)')

console.log(process.env.GREETING ?? '(missing)')
console.log('STRIPE_SECRET_KEY:', mask(process.env.STRIPE_SECRET_KEY))
console.log('DATABASE_URL:', mask(process.env.DATABASE_URL))
