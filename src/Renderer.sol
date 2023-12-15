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
        headTags[1].tagContent =
            "body{font-family:Montserrat,sans-serif;margin:0;padding:0;display:flex;justify-content:center;align-items:center}#c{position:relative}#w{position:absolute;display:flex;flex-direction:column;height:100%;color:#fff;font-weight:400}.t{font-size:min(4vw,4vh)}.l{font-size:min(4vw,4vh)}.s,.u{font-size:min(12vw,12vh);font-weight:800}.u{font-size:min(8vw,8vh);overflow:hidden}.g{flex-grow:1}#a{margin-top:1rem;margin-left:1rem}#z{margin-bottom:1rem;margin-left:1rem}";
        headTags[1].tagClose = "</style>";

        headTags[2].tagOpen = "<script>";
        headTags[2].tagContent =
            'document.addEventListener("DOMContentLoaded",(function(){function t(t,e){return Math.floor(e()*t)}function e(){return window.innerHeight>=window.innerWidth?window.innerWidth:window.innerHeight}const n=document.querySelector("main"),o=(parseInt(n.dataset.seed,10),function(t){const e=2147483647;let n=t%e;return()=>(n=16807*n%e,n/e)}(1e5*Math.random()));let l=t(4,o),i=e(),r=e(),y=r/720,a=4==l?20:3==l?40:2==l?60:1==l?80:120,h=[],c=200,u=100,x=t(6,o);var d=5==x?"#524D61":4==x?"#261356":3==x?"#8A63D2":2==x?"#3F1E94":1==x?"#BAB3CD":"#8A63D2";const f=document.createElement("canvas");f.width=i,f.height=r;document.getElementById("c").appendChild(f);const s=f.getContext("2d");function w(t,e,n){return(1-n)*t+n*e}function m(t,e,n,o,l,i,r){return{x:w(w(t,e,r),w(e,n,r),r),y:w(w(o,l,r),w(l,i,r),r)}}function p(t,e,n,o,l){let i=3*(e-t),r=3*(n-e)-i,y=3*(e-t),a=3*(n-e)-y,h=o-t-y-a;return{x:(o-t-i-r)*Math.pow(l,3)+r*Math.pow(l,2)+i*l+t,y:h*Math.pow(l,3)+a*Math.pow(l,2)+y*l+t}}cols=i/(a*y),rows=r/(a*y);let M={x:360*o()*y,y:360*o()*y},g={x:1e3*o()*y,y:1e3*o()*y},v={x:500*o()*y,y:1e3*o()*y+500*y},D={x:1150*o()*y-150*y,y:1e3*o()*y},A={x:1e3*o()*y,y:1e3*o()*y},C={x:1150*o()*y-150*y,y:1e3*o()*y+500*y};for(let t=0;t<=u/3;t++){let e=m(M.x,g.x,v.x,M.y,g.y,v.y,t/(u/3));h.push(e)}for(let t=0;t<=u/3;t++){let e=t/(u/3),n=p(v.x,D.x,A.x,C.x,e),o=p(v.y,D.y,A.y,C.y,e);h.push({x:n,y:o})}for(let t=0;t<=u/3;t++){let e=t/(u/3),n=w(C.x,M.x,e),o=w(C.y,M.y,e);h.push({x:n,y:o})}for(let t=0;t<=u/2;t++){let e=t/(u/2),n=p(v.x,D.x,A.x,C.x,e),o=p(v.y,D.y,A.y,C.y,e);h.push({x:n,y:o})}let E=0;!function t(){E++,function(){s.canvas.width=e(),s.canvas.height=e(),s.fillStyle=d,s.fillRect(0,0,i,r);for(let t=0;t<c;t++){let e=(E-1+t*u/c+h.length)%h.length,n=h[Math.floor(e)],o=Math.floor(n.x/a)*a,l=Math.floor(n.y/a)*a,i=2*t%360;s.fillStyle=`hsl(${i}, 100%, 50%)`,s.fillRect(o+10,l,a,a)}}(),setTimeout((()=>requestAnimationFrame(t)),25)}()}));';
        headTags[2].tagClose = "</script>";

        HTMLTag[] memory bodyTags = new HTMLTag[](9);
        bodyTags[0].tagContent = '<main id=c data-seed="';
        bodyTags[1].tagContent = bytes(uint256(seed).toString());
        bodyTags[2].tagContent =
            '"><div id=w><div id=a><div class=t>Farcaster Wrapped 2023</div><div class=u>';
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
