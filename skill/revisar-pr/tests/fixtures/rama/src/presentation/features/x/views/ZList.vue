<script setup lang="ts">
// Props
const props = defineProps({ id: String })
const { rows, updatePage } = useZList()
const total = computed(() => rows.length)
const save = async () => {}
// const old = 1
const rule = (val) => !!val || 'Requerido'
</script>
<template>
  <svg xmlns="http://www.w3.org/2000/svg"></svg>
  <TableList :rows="rows" @update-page="updatePage" @click="onMounted" />
  <q-input :rules="[(val) => /^\d+$/.test(val) || 'Solo números']" />
</template>
