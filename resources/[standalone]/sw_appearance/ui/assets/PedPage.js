const __vite__mapDeps=(i,m=__vite__mapDeps,d=(m.f||(m.f=["./Accordion.js","./index.js","./index.css"])))=>i.map(i=>d[i]);
import{d as i,r as u,i as c,o as p,k as _,b as m,e,n as g,z as f,p as b,q as v,_ as k,s as r}from"./index.js";const x={class:"p-2"},y=i({__name:"PedPage",setup(P){const n=v(()=>k(()=>import("./Accordion.js"),__vite__mapDeps([0,1,2]),import.meta.url)),o=u(),s=()=>{r("setGender",{gender:o.value}).then(()=>{})};function d(){r("getGender",{}).then(t=>{o.value=t.gender})}return c(()=>{d()}),(t,a)=>(p(),_(b(n),{label:"Ped",group:"main_menu","header-class":"bg-blue-700"},{default:m(()=>[e("div",x,[g(e("select",{"onUpdate:modelValue":[a[0]||(a[0]=l=>o.value=l),s],class:"uppercase text-xs bg-gray-700 border border-gray-700 text-white block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-red-500 dark:focus:border-red-500"},a[1]||(a[1]=[e("option",{selected:""},"Selecione o ped",-1),e("option",{value:"Masculino"},"Masculino",-1),e("option",{value:"Feminino"},"Feminino",-1)]),512),[[f,o.value]])])]),_:1}))}});export{y as default};