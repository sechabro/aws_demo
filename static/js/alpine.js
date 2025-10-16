import Alpine from '/pkg/alpine/module.esm.js';
window.Alpine = Alpine;

window.ipView = () => ({
  DATA_URL: '/data',
  data: {},
  loading: true,
  loaded: false,
  lastUpdated: '',
  safe(v){ return (v ?? 'wait'); },
  boolLabel(v){ return v === true ? 'Yes' : v === false ? 'No' : 'wait'; },
  scoreClass(s){
    const n = Number(s ?? 0);
    if (n >= 70) return 'bad';
    if (n >= 20) return 'warn';
    return 'ok';
  },
  async load(){
    try {
      this.loading = true;
      const r = await fetch(this.DATA_URL, { headers: { 'Accept': 'application/json' }});
      this.data = await r.json();
      this.loaded = true;
      this.lastUpdated = new Date().toLocaleString();
    } catch (e) {
      console.error(e);
    } finally {
      this.loading = false;
    }
  }
});

Alpine.start();