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

    function htmlRequest(
        uint32 seed,
        uint24 mins,
        uint16 streak,
        string memory username
    ) public pure returns (HTMLTag[] memory, HTMLTag[] memory) {
        HTMLTag[] memory headTags = new HTMLTag[](5);

        headTags[0].tagContent =
            '<link href="https://fonts.googleapis.com" rel="preconnect"/><link href="https://fonts.gstatic.com" rel="preconnect" crossorigin="true"/><link href="https://fonts.googleapis.com/css2?family=Poppins:wght@200;300;400;500;600;700;800;900" rel="stylesheet"/><link href="https://fonts.googleapis.com/css?family=Montserrat:400,800" rel="stylesheet"/>';

        headTags[1].tagContent =
            "<style>body{font-family:Poppins,sans-serif;margin:0;padding:0;display:flex;justify-content:center;align-items:center}#c{position:relative}#w{position:absolute;display:flex;flex-direction:column;height:100%;color:#fff;font-weight:400}.t{font-size:min(4vw,4vh)}.l{font-size:min(4vw,4vh)}.s,.u{font-size:min(16vw,16vh);font-weight:800;font-family:Montserrat,sans-serif}.u{font-size:min(8vw,8vh);overflow:hidden;font-family:Montserrat,sans-serif}.g{flex-grow:1}#a{margin-top:1.5rem;margin-left:1.5rem}#z{margin-bottom:1.5rem;margin-left:1.5rem}#m{margin-bottom:calc(1rem - 8px)}.p{width:100vw;height:100vh;background-color:";
        headTags[2].tagContent = _color(seed);
        headTags[3].tagContent = "}</style>";

        headTags[4].tagContent =
            '<style scoped="true">@media screen and (min-height:720px){#a{margin-top:2.5rem;margin-left:2.5rem}#z{margin-bottom:2.5rem;margin-left:2.5rem}}@media screen and (max-height:450px){#a{margin-top:1rem;margin-left:1rem}#z{margin-bottom:1rem;margin-left:1rem}}@media screen and (max-height:300px){#a{margin-top:.5rem;margin-left:.5rem}#z{margin-bottom:.5rem;margin-left:.5rem}#m{margin-bottom:0}}</style>';

        HTMLTag[] memory bodyTags = new HTMLTag[](12);
        bodyTags[0].tagContent = '<main id="c" class="p" data-color="';
        bodyTags[1].tagContent = _color(seed);
        bodyTags[2].tagContent = '" data-seed="';
        bodyTags[3].tagContent = bytes(uint256(seed).toString());
        bodyTags[4].tagContent =
            '"><div id="w"><div id="a"><div class="t">Farcaster Wrapped 2023</div><div class="u">';
        bodyTags[5].tagContent = bytes(username);
        bodyTags[6].tagContent =
            '</div></div><div class="g"></div><div id="z"><div class="l">Minutes Spent Casting</div><div class="s" id="m">';
        bodyTags[7].tagContent = bytes(uint256(mins).toString());
        bodyTags[8].tagContent =
            '</div><div class="l">Longest Cast Streak</div><div class="s">';
        bodyTags[9].tagContent = bytes(uint256(streak).toString());
        bodyTags[10].tagContent = " days</div></div></div></main>";

        bodyTags[11].tagContent =
            '<script>document.addEventListener("DOMContentLoaded",(function(){function e(){return window.innerHeight>=window.innerWidth?window.innerWidth:window.innerHeight}const t=document.querySelector("main"),n=function(e){const t=2147483647;let n=e%t;return()=>(n=16807*n%t,n/t)}(parseInt(t.dataset.seed,10));let o=function(e,t){return Math.floor(t()*e)}(4,n),y=e(),l=e(),x=l/720,r=4==o?20:3==o?40:2==o?60:1==o?80:120,i=[],a=200,s=100;var c=t.dataset.color;const u=document.createElement("canvas"),h=document.getElementById("c");h.classList.remove("p"),h.appendChild(u);const f=u.getContext("2d");function d(e,t,n){return(1-n)*e+n*t}function w(e,t,n,o,y,l,x){return{x:d(d(e,t,x),d(t,n,x),x),y:d(d(o,y,x),d(y,l,x),x)}}function p(e,t,n,o,y){let l=3*(t-e),x=3*(n-t)-l,r=3*(t-e),i=3*(n-t)-r,a=o-e-r-i;return{x:(o-e-l-x)*Math.pow(y,3)+x*Math.pow(y,2)+l*y+e,y:a*Math.pow(y,3)+i*Math.pow(y,2)+r*y+e}}cols=y/(r*x),rows=l/(r*x);var m=n(),v=n(),M=n(),g=n(),E=n(),L=n(),C=n(),S=n(),q=n(),H=n(),I=n(),R=n();let W={x:360*m*x,y:360*v*x},z={x:1e3*M*x,y:1e3*g*x},A={x:500*E*x,y:1e3*L*x+500*x},B={x:1150*C*x-150*x,y:1e3*S*x},D={x:1e3*q*x,y:1e3*H*x},F={x:1150*I*x-150*x,y:1e3*R*x+500*x};for(let e=0;e<=s/3;e++){let t=w(W.x,z.x,A.x,W.y,z.y,A.y,e/(s/3));i.push(t)}for(let e=0;e<=s/3;e++){let t=e/(s/3),n=p(A.x,B.x,D.x,F.x,t),o=p(A.y,B.y,D.y,F.y,t);i.push({x:n,y:o})}for(let e=0;e<=s/3;e++){let t=e/(s/3),n=d(F.x,W.x,t),o=d(F.y,W.y,t);i.push({x:n,y:o})}for(let e=0;e<=s/2;e++){let t=e/(s/2),n=p(A.x,B.x,D.x,F.x,t),o=p(A.y,B.y,D.y,F.y,t);i.push({x:n,y:o})}let O=0;window.addEventListener("resize",(function(){y=e(),l=e(),x=l/720,r=o==4*x?20*x:3==o?40*x:2==o?60*x:1==o?80*x:120*x,f.canvas.width=y,f.canvas.height=l;let t={x:360*m*x,y:360*v*x},n={x:1e3*M*x,y:1e3*g*x},a={x:500*E*x,y:1e3*L*x+500*x},c={x:1150*C*x-150*x,y:1e3*S*x},u={x:1e3*q*x,y:1e3*H*x},h={x:1150*I*x-150*x,y:1e3*R*x+500*x};i=[];for(let e=0;e<=s/3;e++){let o=w(t.x,n.x,a.x,t.y,n.y,a.y,e/(s/3));i.push(o)}for(let e=0;e<=s/3;e++){let t=e/(s/3),n=p(a.x,c.x,u.x,h.x,t),o=p(a.y,c.y,u.y,h.y,t);i.push({x:n,y:o})}for(let e=0;e<=s/3;e++){let n=e/(s/3),o=d(h.x,t.x,n),y=d(h.y,t.y,n);i.push({x:o,y:y})}for(let e=0;e<=s/2;e++){let t=e/(s/2),n=p(a.x,c.x,u.x,h.x,t),o=p(a.y,c.y,u.y,h.y,t);i.push({x:n,y:o})}})),function t(){O++,function(){f.canvas.width=e(),f.canvas.height=e(),f.fillStyle=c,f.fillRect(0,0,y,l);for(let e=0;e<a;e++){let t=(O-1+e*s/a+i.length)%i.length,n=i[Math.floor(t)],o=Math.floor(n.x/r)*r,y=Math.floor(n.y/r)*r,l=2*e%360;f.fillStyle=`hsl(${l}, 100%, 50%)`,f.fillRect(o,y-10,r,r)}}(),setTimeout((()=>requestAnimationFrame(t)),25)}()}));</script>';

        return (headTags, bodyTags);
    }

    /// @notice Read encoded token HTML
    function htmlURI(
        uint32 seed,
        uint24 mins,
        uint16 streak,
        string memory username
    ) public view returns (bytes memory) {
        (HTMLTag[] memory headTags, HTMLTag[] memory bodyTags) =
            htmlRequest(seed, mins, streak, username);
        return getEncodedHTML(
            HTMLRequest({headTags: headTags, bodyTags: bodyTags})
        );
    }

    function svgURI(
        uint32 seed,
        uint24 mins,
        uint16 streak,
        string memory username
    ) public view returns (bytes memory) {
        (HTMLTag[] memory headTags, HTMLTag[] memory bodyTags) =
            htmlRequest(seed, mins, streak, username);
        headTags[1].tagContent =
            "<style>body{font-family:Poppins,sans-serif;margin:0;padding:0;display:flex;justify-content:center;align-items:center}#c{position:relative}#w{position:absolute;display:flex;flex-direction:column;height:100%;color:#fff;font-weight:400}.t{font-size:28px}.l{font-size:28px}.s,.u{font-size:112px;font-weight:800;font-family:Montserrat,sans-serif}.u{font-size:56px;overflow:hidden;font-family:Montserrat,sans-serif}.g{flex-grow:1}#a{margin-top:1.5rem;margin-left:1.5rem}#z{margin-bottom:1.5rem;margin-left:1.5rem}#m{margin-bottom:calc(1rem - 8px)}.p{width: 700px; height: 700px; background-color:";
        headTags[2].tagContent = _color(seed);
        headTags[3].tagContent = "}</style>";
        headTags[4].tagContent = "<style></style>";
        assembly {
            mstore(bodyTags, 11)
        }
        HTMLRequest memory html =
            HTMLRequest({headTags: headTags, bodyTags: bodyTags});
        bytes memory htmlFile = getHTML(html);
        bytes memory open =
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 700"><foreignObject width="100%" height="100%"><body xmlns="http://www.w3.org/1999/xhtml">';
        bytes memory close = "</body></foreignObject></svg>";

        bytes memory svg =
            DynamicBuffer.allocate(open.length + htmlFile.length + close.length);
        DynamicBuffer.appendSafe(svg, open);
        DynamicBuffer.appendSafe(svg, htmlFile);
        DynamicBuffer.appendSafe(svg, close);

        bytes memory base64URIprefix = "data:image/svg+xml;base64,";

        uint256 sizeForEncoding = sizeForBase64Encoding(svg.length);
        sizeForEncoding += base64URIprefix.length;

        bytes memory encoded = DynamicBuffer.allocate(sizeForEncoding);
        DynamicBuffer.appendSafe(encoded, base64URIprefix);
        DynamicBuffer.appendSafeBase64(encoded, svg, false, false);

        return encoded;
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
                '","image":"',
                svgURI(seed, mins, streak, username),
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

    function _color(uint32 seed) internal pure returns (bytes memory) {
        string[] memory colors = new string[](6);
        colors[0] = "#524D61";
        colors[1] = "#261356";
        colors[2] = "#8A63D2";
        colors[3] = "#3F1E94";
        colors[4] = "#BAB3CD";
        colors[5] = "#8A63D2";
        return bytes(colors[seed % 6]);
    }
}
