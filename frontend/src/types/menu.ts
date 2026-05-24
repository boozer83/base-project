export interface Menu {
  id: number
  name: string
  path: string | null
  parentId: number | null
  sortOrder: number
  children: Menu[]
}
