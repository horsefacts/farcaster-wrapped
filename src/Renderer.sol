// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {LibString} from "solady/src/utils/LibString.sol";
import {ScriptyHTML} from "scripty.sol/scripty/htmlBuilders/ScriptyHTML.sol";
import {
    HTMLRequest,
    HTMLTagType,
    HTMLTag
} from "scripty.sol/scripty/interfaces/IScriptyHTML.sol";
import {DynamicBuffer} from "scripty.sol/scripty/utils/DynamicBuffer.sol";

import {LibDataURI} from "./LibDataURI.sol";

contract Renderer is ScriptyHTML {
    using LibString for uint256;

    /// @notice Read encoded token HTML
    function htmlURI(
        uint32 seed,
        uint24 mins,
        uint16 streak,
        string memory username
    ) public view returns (bytes memory) {
        HTMLTag[] memory headTags = new HTMLTag[](3);

        headTags[0].tagContent =
            '<link href="https://fonts.googleapis.com/css?family=Montserrat:600,800"rel=stylesheet />';

        headTags[1].tagOpen = "<style>";
        headTags[1].tagContent = "body{font-family:Montserrat,sans-serif;margin:0;padding:0;display:flex;justify-content:center;align-items:center}main{width:100vw;height:100vh}#c{position:relative}#w{position:absolute;display:flex;flex-direction:column;height:100%;color:#fff;font-weight:400;width:100%;height:100%}.t{font-size:min(4vw,4vh)}.l{font-size:min(4vw,4vh)}.s,.u{font-size:min(12vw,12vh);font-weight:800}.u{font-size:min(8vw,8vh);overflow:hidden}.g{flex-grow:1}#a{margin-top:2rem;margin-left:2rem}#z{margin-bottom:2rem;margin-left:2rem}.p{background-color:#3f1e94}";

        headTags[1].tagClose = "</style>";

        headTags[2].tagOpen = "<script>";
        headTags[2].tagContent =
        'document.addEventListener("DOMContentLoaded",(function(){function e(e,t){return Math.floor(t()*e)}function t(){return window.innerHeight>=window.innerWidth?window.innerWidth:window.innerHeight}function n(e){const n=t(),i=t(),o=i/720,r=4==l?20:3==l?40:2==l?60:1==l?80:120;return e.width=n,e.height=i,{width:n,height:i,scale:o,gridSize:r}}document.getElementById("w").className="";const i=document.querySelector("main"),o=function(e){const t=2147483647;let n=e%t;return()=>(n=16807*n%t,n/t)}(parseInt(i.dataset.seed,10));let l=e(4,o),r=[],h=200,d=100,c=e(6,o);var u=5==c?"#524D61":4==c?"#261356":3==c?"#8A63D2":2==c?"#3F1E94":1==c?"#BAB3CD":"#8A63D2";const y=document.createElement("canvas");let{width:a,height:x,scale:s,gridSize:f}=n(y);document.getElementById("c").appendChild(y);const w=y.getContext("2d");function g(e,t,n){return(1-n)*e+n*t}function m(e,t,n,i,o,l,r){return{x:g(g(e,t,r),g(t,n,r),r),y:g(g(i,o,r),g(o,l,r),r)}}function p(e,t,n,i,o){let l=3*(t-e),r=3*(n-t)-l,h=3*(t-e),d=3*(n-t)-h,c=i-e-h-d;return{x:(i-e-l-r)*Math.pow(o,3)+r*Math.pow(o,2)+l*o+e,y:c*Math.pow(o,3)+d*Math.pow(o,2)+h*o+e}}let M={x:360*o()*s,y:360*o()*s},S={x:1e3*o()*s,y:1e3*o()*s},E={x:500*o()*s,y:1e3*o()*s+500*s},z={x:1150*o()*s-150*s,y:1e3*o()*s},D={x:1e3*o()*s,y:1e3*o()*s},v={x:1150*o()*s-150*s,y:1e3*o()*s+500*s};for(let e=0;e<=d/3;e++){let t=m(M.x,S.x,E.x,M.y,S.y,E.y,e/(d/3));r.push(t)}for(let e=0;e<=d/3;e++){let t=e/(d/3),n=p(E.x,z.x,D.x,v.x,t),i=p(E.y,z.y,D.y,v.y,t);r.push({x:n,y:i})}for(let e=0;e<=d/3;e++){let t=e/(d/3),n=g(v.x,M.x,t),i=g(v.y,M.y,t);r.push({x:n,y:i})}for(let e=0;e<=d/2;e++){let t=e/(d/2),n=p(E.x,z.x,D.x,v.x,t),i=p(E.y,z.y,D.y,v.y,t);r.push({x:n,y:i})}let A=0;window.addEventListener("resize",(()=>{({width:a,height:x,scale:s,gridSize:f}=n(y)),console.log("uhhhhh............")})),function e(){A++,function(){let{width:e,height:t,gridSize:i}=n(y);w.fillStyle=u,w.fillRect(0,0,e,t);for(let e=0;e<h;e++){let t=(A-1+e*d/h+r.length)%r.length,n=r[Math.floor(t)],o=Math.floor(n.x/i)*i,l=Math.floor(n.y/i)*i,c=2*e%360;w.fillStyle=`hsl(${c}, 100%, 50%)`,w.fillRect(o+10,l,i,i)}}(),setTimeout((()=>requestAnimationFrame(e)),25)}()}));';
        headTags[2].tagClose = "</script>";

        HTMLTag[] memory bodyTags = new HTMLTag[](9);
        bodyTags[0].tagContent = '<main id=c data-seed="';
        bodyTags[1].tagContent = bytes(uint256(seed).toString());
        bodyTags[2].tagContent =
            '"><div id=w class=p><div id=a><div class=t>Farcaster Wrapped 2023</div><div class=u>';
        bodyTags[3].tagContent = bytes(username);
        bodyTags[4].tagContent =
            "</div></div><div class=g></div><div id=z><div class=l>Minutes Spent Casting</div><div class=s>";
        bodyTags[5].tagContent = bytes(uint256(mins).toString());
        bodyTags[6].tagContent =
            "</div><div class=l>Longest Cast Streak</div><div class=s>";
        bodyTags[7].tagContent = bytes(uint256(streak).toString());
        bodyTags[8].tagContent = " days</div></div></div></main>";

        HTMLRequest memory htmlRequest;
        htmlRequest.headTags = headTags;
        htmlRequest.bodyTags = bodyTags;

        return getEncodedHTML(htmlRequest);
    }

    /// @notice Read token metadata JSON
    function tokenJSON(
        uint32 seed,
        uint256 fid,
        uint24 mins,
        uint16 streak,
        string memory username
    ) public view returns (string memory) {
        return string(
            abi.encodePacked(
                '{"animation_url":"',
                htmlURI(seed, mins, streak, username),
                '","name":"FID #',
                fid.toString(),
                '","attributes":[{"trait_type":"Minutes Spent Casting","value":',
                uint256(mins).toString(),
                '},{"trait_type":"Streak","value":',
                uint256(streak).toString(),
                '},{"trait_type":"Username","value":"',
                username,
                '"}]}'
            )
        );
    }

    /// @notice Read contract metadata JSON
    function contractJSON() public pure returns (string memory) {
        return
        '{"name":"Farcaster Wrapped 2023","image":"ipfs://bafkreicxcw7vkzh33py2pqx6gxp2vdq2ccxrk4qoocrtihyct4nevhazjm","description":"A commemorative NFT for all the people involved in proliferating the Farcaster protocol in 2023"}';
    }
}
