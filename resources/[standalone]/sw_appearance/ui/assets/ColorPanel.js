import{d as m,m as p,u as f,y as h,o as t,c as l,e as a,t as c,F as b,l as C,A as _,C as v,f as g}from"./index.js";import{c as y,H as k}from"./utils.js";const x={class:"border-white border-2 flex flex-col mb-2"},M={class:"text-center text-sp font-bold mb-1"},w={class:"grid grid-cols-8 gap-1 text-sp"},V=["onClick"],N=m({__name:"ColorPanel",props:p({colorType:{default:"hair"},label:{}},{modelValue:{default:0,type:Number},modelModifiers:{}}),emits:["update:modelValue"],setup(r){const n=r,o=f(r,"modelValue"),i=h(()=>{switch(n.colorType){case"hair":return k;case"makeup":return y}}),d=e=>{o.value!=e&&(o.value=e)};return(e,B)=>(t(),l("div",x,[a("span",M,c(e.label),1),a("div",w,[(t(!0),l(b,null,C(i.value,(u,s)=>(t(),l("div",{class:_(["min-h-6 flex flex-col justify-center items-center font-bold cursor-pointer hover:scale-110",{"border-2 border-white":o.value==s}]),style:v({backgroundColor:u}),onClick:g(z=>d(s),["stop"])},c(s),15,V))),256))])]))}});export{N as default};