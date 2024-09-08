const a=(s,o)=>Object.fromEntries(Object.entries(s).map(([n,t],e)=>[n,o(t,n,e)]));function c(s,o){return s.reduce((t,e)=>(t[e[o]]||(t[e[o]]=[]),t[e[o]].push(e),t),{})}export{c as g,a as o};
