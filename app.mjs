// Stands in for your actual app: it validates the env it needs, then proves
// the values arrived. Forget a key and this is what screams, not your app
// three screens into a request.
import { z } from 'zod'

const schema = z.object({
  STRIPE_SECRET_KEY: z.string().startsWith('sk_test_', 'must be a Stripe *test* key'),
  DATABASE_URL: z.url(),
  GREETING: z.string().min(1),
})

const env = schema.safeParse(process.env)

if (!env.success) {
  console.error('Bad or missing secrets. Run `pnpm secrets` and fix secrets/dev.yaml:\n')
  for (const issue of env.error.issues) {
    console.error(`  ${issue.path.join('.')}: ${issue.message}`)
  }
  process.exit(1)
}

const mask = (v) => v.slice(0, 8) + '…'

console.log(env.data.GREETING)
console.log('STRIPE_SECRET_KEY:', mask(env.data.STRIPE_SECRET_KEY))
console.log('DATABASE_URL:', mask(env.data.DATABASE_URL))
