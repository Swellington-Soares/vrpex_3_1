const __vite__mapDeps=(i,m=__vite__mapDeps,d=(m.f||(m.f=["./Accordion.js","./index.js","./index.css"])))=>i.map(i=>d[i]);
import{d as I,y as r,r as s,i as S,j as V,o as T,k as B,b as U,e as t,n as o,v as i,p as $,q as O,_ as A,s as y}from"./index.js";import{M as u,b as d}from"./utils.js";const H={class:"bg-blue-950"},_={class:"flex flex-col pl-1 pr-1"},C=["max"],E={class:"flex flex-col pl-1 pr-1"},q=["max"],D={class:"flex flex-col pl-1 pr-1"},N=["max"],R={class:"flex flex-col pl-1 pr-1"},j=["max"],L={class:"flex flex-col pl-1 pr-1"},z={class:"flex flex-col pl-1 pr-1"},Q=I({__name:"ParentPage",setup(G){const M=O(()=>A(()=>import("./Accordion.js"),__vite__mapDeps([0,1,2]),import.meta.url)),f=r(()=>u.length),c=r(()=>d.length),m=s(0),p=s(0),g=s(0),b=s(0),x=s(0),v=s(0),h=r(()=>u[m.value]),P=r(()=>d[p.value]),w=r(()=>u[g.value]),F=r(()=>d[b.value]);function k(){y("getHeadblend",{}).then(a=>{x.value=parseFloat(a.shapeMix.toPrecision(2)),v.value=parseFloat(a.skinMix.toPrecision(2)),m.value=u.indexOf(a.shapeFirst),p.value=d.indexOf(a.shapeSecond),g.value=u.indexOf(a.skinFirst),b.value=d.indexOf(a.skinSecond)})}function l(){var a,e;y("setHeadBlend",{hasParent:!1,shapeFirst:h.value,shapeSecond:P.value,skinFirst:w.value,skinSecond:F.value,skinMix:parseFloat((a=v.value)==null?void 0:a.toPrecision(2)),shapeMix:parseFloat((e=x.value)==null?void 0:e.toPrecision(2)),shapeThird:0,skinThird:0,thirdMix:0})}return S(()=>{k()}),V("updatePed",()=>{k()}),(a,e)=>(T(),B($(M),{label:"Pais",group:"main_menu","header-class":"bg-blue-700"},{default:U(()=>[t("div",H,[t("div",_,[e[12]||(e[12]=t("label",{for:"range-1",class:"pt-1 text-md pb-1 block text-center bg-blue-900 mt-2 mb-3 font-medium text-white uppercase"},"Mãe",-1)),o(t("input",{id:"range-1",type:"range",class:"w-full h-1 mb-6 bg-gray-200 rounded-lg appearance-none cursor-pointer range-sm dark:bg-gray-700",min:0,max:f.value,"onUpdate:modelValue":[e[0]||(e[0]=n=>m.value=n),e[1]||(e[1]=n=>l())]},null,8,C),[[i,m.value,void 0,{number:!0}]])]),t("div",E,[e[13]||(e[13]=t("label",{for:"range-2",class:"block text-center bg-blue-900 mt-2 mb-3 text-md font-medium text-white uppercase"},"Pai",-1)),o(t("input",{id:"range-2",type:"range",class:"w-full h-1 mb-6 bg-gray-200 rounded-lg appearance-none cursor-pointer range-sm dark:bg-gray-700",min:0,max:c.value,"onUpdate:modelValue":[e[2]||(e[2]=n=>p.value=n),e[3]||(e[3]=n=>l())]},null,8,q),[[i,p.value,void 0,{number:!0}]])]),t("div",D,[e[14]||(e[14]=t("label",{for:"range-3",class:"block text-center bg-blue-900 mt-2 mb-3 text-md font-medium text-white uppercase"},"Tom da Pele Mãe",-1)),o(t("input",{id:"range-3",type:"range",class:"w-full h-1 mb-6 bg-gray-200 rounded-lg appearance-none cursor-pointer range-sm dark:bg-gray-700",min:0,max:f.value,"onUpdate:modelValue":[e[4]||(e[4]=n=>g.value=n),e[5]||(e[5]=n=>l())]},null,8,N),[[i,g.value,void 0,{number:!0}]])]),t("div",R,[e[15]||(e[15]=t("label",{for:"range-4",class:"block text-center bg-blue-900 mt-2 mb-3 text-md font-medium text-white uppercase"},"Tom da Pele Pai",-1)),o(t("input",{id:"range-4",type:"range",class:"w-full h-1 mb-6 bg-gray-200 rounded-lg appearance-none cursor-pointer range-sm dark:bg-gray-700",min:0,max:c.value,"onUpdate:modelValue":[e[6]||(e[6]=n=>b.value=n),e[7]||(e[7]=n=>l())]},null,8,j),[[i,b.value,void 0,{number:!0}]])]),t("div",L,[e[16]||(e[16]=t("label",{for:"range-5",class:"block text-center bg-blue-900 mt-2 mb-3 text-md font-medium text-white uppercase"},"Ancestralidade",-1)),o(t("input",{id:"range-5",type:"range",class:"w-full h-1 mb-6 bg-gray-200 rounded-lg appearance-none cursor-pointer range-sm dark:bg-gray-700",min:0,max:1,step:.01,"onUpdate:modelValue":[e[8]||(e[8]=n=>x.value=n),e[9]||(e[9]=n=>l())]},null,512),[[i,x.value,void 0,{number:!0}]])]),t("div",z,[e[17]||(e[17]=t("label",{for:"range-6",class:"block text-center bg-blue-900 mt-2 mb-3 text-md font-medium text-white uppercase"},"Mistura de Tom",-1)),o(t("input",{id:"range-6",type:"range",class:"w-full h-1 mb-6 bg-gray-200 rounded-lg appearance-none cursor-pointer range-sm dark:bg-gray-700",min:0,max:1,step:.01,"onUpdate:modelValue":[e[10]||(e[10]=n=>v.value=n),e[11]||(e[11]=n=>l())]},null,512),[[i,v.value,void 0,{number:!0}]])])])]),_:1}))}});export{Q as default};
