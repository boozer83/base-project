export const PERMISSIONS = {
  NOTICE_WRITE: 'NOTICE_WRITE',
  SAMPLE_ACCESS: 'SAMPLE_ACCESS',
  ADMIN_ACCESS: 'ADMIN_ACCESS',
} as const

export type Permission = (typeof PERMISSIONS)[keyof typeof PERMISSIONS]
