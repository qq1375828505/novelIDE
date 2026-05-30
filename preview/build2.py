# -*- coding: utf-8 -*-
"""
网文写作IDE 预览 - 完整功能版
核心原则：用户交互体验第一
- 主屏：AI对话（最大面积，核心交互）
- 左侧栏：作品管理 + 资料 + 历史（内容入口）
- 底部工具栏：所有功能一键触达（工具入口）
- 右侧详情：章节/资料详情（上下文操作）
- 设置：深层配置（最少触达）
"""
import os
out = r'D:\AI\preview\index.html'

HTML = r"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>网文写作IDE</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
:root{
  --bg:#fff;--bg2:#f7f7f8;--bg3:#ececf1;--text:#1a1a1a;--text2:#6b6b6b;
  --bu:#f0f0f0;--ba:#e8f4fd;--ac:#10a37f;--ac2:#0d8c6e;
  --sb:#fff;--ol:rgba(0,0,0,.4);--bd:#e5e5e5;
  --sh:0 2px 12px rgba(0,0,0,.08);--r:16px;
}
[data-theme=dark]{
  --bg:#212121;--bg2:#2f2f2f;--bg3:#3e3e3e;--text:#ececec;--text2:#9a9a9a;
  --bu:#303030;--ba:#1a3a4a;--ac:#10a37f;--ac2:#0d8c6e;
  --sb:#1e1e1e;--ol:rgba(0,0,0,.6);--bd:#444;
}
body{font-family:system-ui,-apple-system,sans-serif;background:var(--bg2);color:var(--text);height:100vh;overflow:hidden;display:flex;justify-content:center}
.phone{width:375px;height:100dvh;background:var(--bg);display:flex;flex-direction:column;position:relative;overflow:hidden}

/* ====== TOP BAR ====== */
.topbar{display:flex;align-items:center;padding:10px 14px;background:var(--bg);border-bottom:1px solid var(--bd);min-height:52px;flex-shrink:0}
.ib{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;background:none;border:none;font-size:18px;cursor:pointer;color:var(--text)}
.ib:active{background:var(--bg2)}
.tb{flex:1;text-align:center;cursor:pointer}
.tb .t{font-weight:600;font-size:15px}
.mc{font-size:11px;background:var(--bg2);border:1px solid var(--bd);border-radius:8px;padding:2px 8px;color:var(--text2);display:inline-block;margin-top:2px}

/* ====== MODEL DROPDOWN ====== */
.md{position:absolute;top:52px;left:50%;transform:translateX(-50%);width:280px;background:var(--sb);border:1px solid var(--bd);border-radius:var(--r);box-shadow:var(--sh);z-index:20;padding:8px;display:none}
.md.open{display:block;animation:fi .2s}
.mi{padding:10px 12px;border-radius:10px;cursor:pointer;font-size:14px;display:flex;align-items:center;gap:8px}
.mi:hover,.mi.ac{background:var(--bg2)}.mi.ac::after{content:"\2713";margin-left:auto;color:var(--ac);font-weight:bold}
.mdiv{height:1px;background:var(--bd);margin:6px 0}
.mi .tag{font-size:10px;background:var(--bg3);padding:1px 6px;border-radius:4px;margin-left:4px}

/* ====== CHAT AREA ====== */
.chat{flex:1;overflow-y:auto;padding:16px 14px 8px;scroll-behavior:smooth}
.msg{display:flex;gap:8px;margin-bottom:14px;animation:fi .3s}.msg.u{flex-direction:row-reverse}
.av{width:28px;height:28px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0}
.msg.u .av{background:#6366f1;color:#fff}.msg.a .av{background:var(--ac);color:#fff}
.bub{max-width:80%;padding:10px 14px;border-radius:var(--r);font-size:14px;line-height:1.6}
.msg.u .bub{background:var(--bu);border-bottom-right-radius:4px}.msg.a .bub{background:var(--ba);border-bottom-left-radius:4px}
.bub .tool-tag{display:inline-block;font-size:11px;background:var(--ac);color:#fff;padding:1px 8px;border-radius:4px;margin:4px 2px 0 0}
.bub .save-tag{font-size:12px;color:var(--ac);display:block;margin-top:6px}
.typ{display:flex;gap:4px;padding:6px 0}.typ span{width:6px;height:6px;background:var(--text2);border-radius:50%;animation:bn .6s infinite alternate}
.typ span:nth-child(2){animation-delay:.2s}.typ span:nth-child(3){animation-delay:.4s}
@keyframes bn{to{opacity:.3;transform:translateY(-4px)}}
@keyframes fi{from{opacity:0;transform:translateY(6px)}to{opacity:1;transform:none}}

/* ====== QUICK ACTION BAR ====== */
.qbar{display:flex;gap:8px;padding:8px 14px;overflow-x:auto;background:var(--bg);border-top:1px solid var(--bd);flex-shrink:0}
.qrow{display:flex;gap:6px;overflow-x:auto;-webkit-overflow-scrolling:touch}.qrow::-webkit-scrollbar{display:none}
.qp{flex-shrink:0;padding:5px 12px;border-radius:16px;font-size:12px;background:var(--bg2);border:1px solid var(--bd);cursor:pointer;white-space:nowrap;display:flex;align-items:center;gap:4px}
.qp:active{background:var(--ac);color:#fff}
.qp .qi{font-size:14px}

/* ====== AGENT/SKILL SELECTOR ====== */
.asel{display:none;padding:8px 14px;background:var(--sb);border-top:1px solid var(--bd);flex-shrink:0}
.asel.open{display:block;animation:fi .2s}
.asel-title{font-size:12px;color:var(--text2);margin-bottom:8px;display:flex;justify-content:space-between;align-items:center}
.asel-title .close{cursor:pointer;font-size:16px;color:var(--text2)}
.agrid{display:flex;gap:8px;overflow-x:auto;padding-bottom:4px}.agrid::-webkit-scrollbar{display:none}
.acard{flex-shrink:0;width:120px;padding:10px;border-radius:12px;background:var(--bg2);border:1px solid var(--bd);cursor:pointer}
.acard:active,.acard.ac{border-color:var(--ac);background:rgba(16,163,127,.08)}
.acard .an{font-size:13px;font-weight:600;margin-bottom:4px}
.acard .ad{font-size:11px;color:var(--text2);line-height:1.3}

/* ====== INPUT BAR ====== */
.ia{display:flex;align-items:flex-end;gap:8px;padding:8px 14px;background:var(--bg);flex-shrink:0;border-top:1px solid var(--bd)}
.ia textarea{flex:1;border:1px solid var(--bd);border-radius:20px;padding:8px 14px;font-size:14px;background:var(--bg2);color:var(--text);resize:none;outline:none;max-height:100px;font-family:inherit}
.ia textarea::placeholder{color:var(--text2)}
.sb{width:36px;height:36px;border-radius:50%;background:var(--ac);border:none;color:#fff;font-size:16px;cursor:pointer;display:flex;align-items:center;justify-content:center}.sb:active{background:var(--ac2)}
.eb{width:36px;height:36px;border-radius:50%;background:none;border:1px solid var(--bd);font-size:16px;cursor:pointer;display:flex;align-items:center;justify-content:center;color:var(--text2)}.eb:active{background:var(--bg2)}

/* ====== OVERLAYS ====== */
.ov{position:absolute;inset:0;background:var(--ol);z-index:30;opacity:0;pointer-events:none;transition:opacity .3s}.ov.open{opacity:1;pointer-events:auto}

/* ====== LEFT SIDEBAR ====== */
.sd{position:absolute;top:0;left:-280px;width:280px;height:100%;background:var(--sb);z-index:31;transition:left .3s;overflow-y:auto;border-right:1px solid var(--bd)}.sd.open{left:0}
.sh{padding:14px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--bd)}
.sh .nc{flex:1;padding:10px;border-radius:10px;border:1px solid var(--bd);background:none;font-size:14px;cursor:pointer;text-align:left;color:var(--text)}
.ss{padding:4px 10px}.sst{font-size:12px;font-weight:600;color:var(--text2);padding:10px 4px 4px}
.ci{padding:10px 12px;border-radius:10px;cursor:pointer;font-size:13px;color:var(--text);line-height:1.4}.ci:hover{background:var(--bg2)}.ci .tm{font-size:11px;color:var(--text2);display:block;margin-top:2px}
.tn{display:flex;align-items:center;gap:6px;padding:7px 10px;cursor:pointer;font-size:13px;border-radius:6px;color:var(--text)}.tn:hover{background:var(--bg2)}
.ar{width:16px;text-align:center;font-size:10px;color:var(--text2);transition:transform .2s;flex-shrink:0}.ar.op{transform:rotate(90deg)}
.tc{padding-left:16px;display:none}.tc.open{display:block}
.tl{display:flex;align-items:center;gap:6px;padding:5px 10px 5px 26px;font-size:13px;cursor:pointer;border-radius:6px;color:var(--text2)}.tl:hover{background:var(--bg2)}
.bg{font-size:10px;padding:1px 6px;border-radius:4px;margin-left:auto}
.bg.dr{background:#fff3cd;color:#856404}.bg.dn{background:#d4edda;color:#155724}.bg.em{background:#e2e3e5;color:#383d41}.bg.bl{background:#cce5ff;color:#004085}
.sbb{padding:12px 14px;border-top:1px solid var(--bd);display:flex;gap:10px;position:sticky;bottom:0;background:var(--sb)}
.sbb button{flex:1;padding:10px;border-radius:10px;border:1px solid var(--bd);background:none;font-size:13px;cursor:pointer;color:var(--text)}.sbb button:active{background:var(--bg2)}

/* ====== RIGHT PANEL (Chapter) ====== */
.rp{position:absolute;top:0;right:-320px;width:300px;height:100%;background:var(--sb);z-index:31;transition:right .3s;overflow-y:auto;border-left:1px solid var(--bd);padding:16px}.rp.open{right:0}
.ro{position:absolute;inset:0;background:var(--ol);z-index:30;opacity:0;pointer-events:none;transition:opacity .3s}.ro.open{opacity:1;pointer-events:auto}
.sti{display:flex;align-items:center;padding:12px 0;border-bottom:1px solid var(--bd);cursor:pointer;gap:12px}
.sti .lb{flex:1;font-size:14px}

/* ====== BOTTOM SHEET ====== */
.sho{position:absolute;inset:0;background:var(--ol);z-index:30;opacity:0;pointer-events:none;transition:opacity .3s}.sho.open{opacity:1;pointer-events:auto}
.sh2{position:absolute;bottom:-460px;left:0;right:0;background:var(--sb);border-radius:16px 16px 0 0;z-index:31;transition:bottom .3s;padding:16px 16px 24px}.sh2.open{bottom:0}
.shh{width:36px;height:4px;background:var(--bd);border-radius:2px;margin:0 auto 12px}
.sht{font-size:15px;font-weight:600;margin-bottom:12px;text-align:center}
.sgr{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.si{padding:14px;border-radius:12px;background:var(--bg2);cursor:pointer;text-align:center;font-size:13px;border:1px solid transparent}.si:active{background:var(--ac);color:#fff;border-color:var(--ac)}
.si .ic{font-size:24px;display:block;margin-bottom:4px}
.si .st{font-size:10px;color:var(--text2);display:block;margin-top:2px}

/* ====== EXPORT PANEL ====== */
.expo{position:absolute;top:0;left:0;right:0;bottom:100%;background:var(--bg);z-index:32;transform:translateX(100%);transition:transform .3s;overflow-y:auto}.expo.open{transform:none}
.expo .sh{padding:14px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--bd);position:sticky;top:0;background:var(--bg);z-index:2}
.expo h2{font-size:16px;font-weight:600}
.exfmt{margin:12px 14px;padding:16px;border-radius:12px;border:1px solid var(--bd);cursor:pointer}
.exfmt:active{border-color:var(--ac);background:rgba(16,163,127,.05)}
.exfmt .efn{font-size:15px;font-weight:600;margin-bottom:4px}
.exfmt .efd{font-size:12px;color:var(--text2)}
.exopt{margin:8px 14px;padding:10px 14px;background:var(--bg2);border-radius:10px;display:flex;align-items:center;justify-content:space-between;font-size:13px}
.exopt label{display:flex;align-items:center;gap:8px;cursor:pointer}

/* ====== SETTINGS ====== */
.sto{position:absolute;inset:0;background:var(--bg);z-index:32;transform:translateX(100%);transition:transform .3s;overflow-y:auto}.sto.open{transform:none}
.sth{display:flex;align-items:center;padding:14px;gap:10px;border-bottom:1px solid var(--bd);position:sticky;top:0;background:var(--bg);z-index:2}
.sth .bk{width:36px;height:36px;border:none;background:none;font-size:18px;cursor:pointer;color:var(--text)}
.sth h2{font-size:16px;font-weight:600}
.sts{padding:0 14px}.sts h3{font-size:12px;color:var(--text2);padding:16px 0 6px;font-weight:600;text-transform:uppercase}
.sti2{display:flex;align-items:center;padding:14px 0;border-bottom:1px solid var(--bd);cursor:pointer;gap:12px}
.sti2 .lb{flex:1;font-size:14px}.sti2 .sb3{font-size:12px;color:var(--text2)}.sti2 .ar2{color:var(--text2)}
.tg{width:44px;height:26px;border-radius:13px;background:var(--bd);position:relative;cursor:pointer;border:none;transition:background .2s;flex-shrink:0}.tg.on{background:var(--ac)}
.tg::after{content:"";position:absolute;width:22px;height:22px;border-radius:50%;background:#fff;top:2px;left:2px;transition:transform .2s}.tg.on::after{transform:translateX(18px)}
.skg{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;padding:8px 0}
.sk{padding:12px 6px;border-radius:10px;text-align:center;cursor:pointer;border:2px solid transparent;font-size:11px}.sk.ac{border-color:var(--ac)}
.wg{display:flex;align-items:center;gap:12px;padding:10px 0}
.wg button{width:30px;height:30px;border-radius:50%;border:1px solid var(--bd);background:none;font-size:16px;cursor:pointer;color:var(--text)}
.wg .nm{font-size:18px;font-weight:bold;width:80px;text-align:center}
.mp-tab{cursor:pointer}.mp-tab.ac{background:var(--ac);color:#fff;border-color:var(--ac)}
.mp-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;cursor:pointer;font-size:13px}
.mp-item:hover{background:var(--bg2)}
.mp-item input[type=checkbox]{width:18px;height:18px;accent-color:var(--ac)}
.mp-preview{font-size:11px;color:var(--text2);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:200px}
</style>
</head>
<body>
<div class="phone" id="app">

<!-- ====== TOP BAR ====== -->
<div class="topbar">
  <button class="ib" onclick="tS()">&#9776;</button>
  <div class="tb" onclick="tM()">
    <div class="t">网文写作IDE</div>
    <div class="mc" id="mC">GLM-4.7-Flash</div>
  </div>
  <button class="ib" onclick="tT()" id="tB">&#127769;</button>
  <button class="ib" onclick="oSt()">&#9881;</button>
</div>

<!-- ====== MODEL SELECTOR ====== -->
<div class="md" id="mD">
  <div class="mi ac" onclick="sM(this,0)">GLM-4.7-Flash <span class="tag">内置免费</span></div>
  <div class="mi" onclick="sM(this,1)">GLM-4.6V-Flash <span class="tag">多模态</span></div>
  <div class="mi" onclick="sM(this,2)">GLM-4.1V-Thinking <span class="tag">思考版</span></div>
  <div class="mdiv"></div>
  <div class="mi" onclick="sM(this,3)">GPT-4o</div>
  <div class="mi" onclick="sM(this,4)">Claude Sonnet</div>
  <div class="mi" onclick="sM(this,5)">DeepSeek V3</div>
  <div class="mi" onclick="sM(this,6)">本地 Ollama</div>
  <div class="mdiv"></div>
  <div class="mi" style="color:var(--ac);font-size:13px" onclick="cM();oSt()">&#9881; 管理模型</div>
</div>

<!-- ====== CHAT AREA ====== -->
<div class="chat" id="cA">
  <div class="msg u"><div class="av">&#128100;</div><div class="bub">帮我写一部都市修仙小说的大纲，主角是退伍特种兵</div></div>
  <div class="msg a"><div class="av">AI</div><div class="bub"><b>《都市修仙传》大纲草案</b><br><br><b>第一卷：觉醒</b><br>主角林逸，退伍特种兵，在一次意外中激活体内远古血脉...<br><br><b>第二卷：初露锋芒</b><br>林逸在龙城崐露头角，面对修仙界挑战...<br><br>需要我详细展开某一卷吗？<span class="save-tag">&#128161; 已自动保存到资料库</span></div></div>
  <div class="msg u"><div class="av">&#128100;</div><div class="bub">展开第一卷，写出5章的章纲</div></div>
  <div class="msg a"><div class="av">AI</div><div class="bub"><span class="tool-tag">Skill: 大纲生成</span><br><b>第一卷「觉醒」章纲</b><br><br><b>第1章 退婚</b><br>林逸退伍归来，遭遇未婚妻当众退婚羞辱...<br><b>第2章 偶遇</b><br>在山中救下受伤老者，获得修炼功法...<br><b>第3章 觉醒</b><br>修炼功法，体内远古血脉首次觉醒...<br><br><span class="save-tag">&#128161; 已保存5章到作品「都市神医」第一卷</span></div></div>
  <div class="msg u"><div class="av">&#128100;</div><div class="bub">帮我检查第1章的爽点分布</div></div>
  <div class="msg a"><div class="av">AI</div><div class="bub"><span class="tool-tag">Agent: 爽点检查器</span><br><b>第1章 退婚 - 爽点分析报告</b><br><br>&#9989; 开头冲突设置强烈（退婚场景）<br>&#9989; 第3段反转（老者现身）<br>&#9888; 中段节奏偏慢，建议增加冲突<br>&#10060; 结尾缺乏悬念钩子<br><br><span style="font-size:12px;color:var(--text2)">整体爽点评分: 7.2/10</span></div></div>
  <div id="cE"></div>
</div>

<!-- ====== QUICK ACTION BAR ====== -->
<div class="qbar" id="qbar">
  <div class="qrow">
    <div class="qp" onclick="sP('续写下一段')"><span class="qi">&#9998;</span>续写</div>
    <div class="qp" onclick="sP('润色当前段落')"><span class="qi">&#10024;</span>润色</div>
    <div class="qp" onclick="sP('生成完整大纲')"><span class="qi">&#128203;</span>大纲</div>
    <div class="qp" onclick="sP('分析角色关系')"><span class="qi">&#128100;</span>角色</div>
    <div class="qp" onclick="sP('校对全文')"><span class="qi">&#128269;</span>校对</div>
    <div class="qp" onclick="sP('全文审查')"><span class="qi">&#128202;</span>审查</div>
    <div class="qp" onclick="oASel()"><span class="qi">&#129302;</span>Agent</div>
  </div>
</div>

<!-- ====== AGENT/SKILL SELECTOR ====== -->
<div class="asel" id="asel">
  <div class="asel-title">
    <span>&#129302; 选择 Agent / Skill</span>
    <span class="close" onclick="cASel()">&#10005;</span>
  </div>
  <div style="font-size:12px;color:var(--text2);margin-bottom:6px">Agent（智能体）</div>
  <div class="agrid">
    <div class="acard ac"><div class="an">&#128293; 爽点检查器</div><div class="ad">检测章节爽点分布，给出评分</div></div>
    <div class="acard"><div class="an">&#128167; 水文检测器</div><div class="ad">找出注水段落，建议精简</div></div>
    <div class="acard"><div class="an">&#127919; 大纲生成器</div><div class="ad">根据设定自动生成多卷大纲</div></div>
    <div class="acard"><div class="an">&#128172; 标题生成器</div><div class="ad">生成吸引人的章节标题</div></div>
  </div>
  <div style="font-size:12px;color:var(--text2);margin:10px 0 6px">Skill（写作技巧）</div>
  <div class="agrid">
    <div class="acard"><div class="an">&#128218; 金庸风格</div><div class="ad">武侠文风，古风用语</div></div>
    <div class="acard"><div class="an">&#128171; 爽文模板</div><div class="ad">快节奏，高密度爽点</div></div>
    <div class="acard"><div class="an">&#128221; 文学润色</div><div class="ad">提升文笔质量</div></div>
  </div>
  <div style="font-size:12px;color:var(--text2);margin:10px 0 6px">番茄写作（25种风格预设）</div>
  <div class="agrid">
    <div class="acard"><div class="an">&#127813; 都市爽文</div><div class="ad">快节奏升级流</div></div>
    <div class="acard"><div class="an">&#127813; 言情甜宠</div><div class="ad">轻松甜蜜恋爱</div></div>
    <div class="acard"><div class="an">&#127813; 悬疑推理</div><div class="ad">烧脑反转剧情</div></div>
  </div>
  <div style="font-size:12px;color:var(--text2);margin:10px 0 6px">对话模式</div>
  <div class="agrid">
    <div class="acard"><div class="an">&#128172; 语音通话</div><div class="ad">实时语音AI对话</div></div>
  </div>
</div>

<!-- ====== INPUT BAR ====== -->
<div class="ia">
  <button class="eb" onclick="tSh()" title="更多功能">+</button>
  <textarea id="inp" rows="1" placeholder="输入消息，或选择上方操作..." oninput="aG(this)"></textarea>
  <button class="eb" onclick="toggleVoice()" title="语音输入" id="micBtn">&#127908;</button>
  <button class="sb" onclick="sMs()" title="发送">&#9654;</button>
</div>

<!-- ====== LEFT SIDEBAR ====== -->
<div class="ov" id="sO" onclick="cS()"></div>
<div class="sd" id="sB">
  <div class="sh">
    <button class="nc" onclick="newSession()">+ 新会话</button>
  </div>

  <!-- 历史会话 -->
  <div class="ss">
    <div class="sst">历史会话</div>
    <div class="ci">都市神医开篇讨论<span class="tm">今天 14:30</span></div>
    <div class="ci">大纲优化建议<span class="tm">昨天 20:15</span></div>
    <div class="ci">角色关系梳理<span class="tm">5月28日</span></div>
  </div>

  <!-- 作品工作树 -->
  <div class="ss">
    <div class="sst">作品</div>
    <!-- 都市神医 -->
    <div class="tn" onclick="tN(this)"><span class="ar">&#9654;</span> &#128214; 都市神医 <span style="margin-left:auto;font-size:11px;color:var(--text2)">3卷15章</span></div>
    <div class="tc">
      <div class="tn" onclick="tN(this)"><span class="ar">&#9654;</span> &#128193; 第一卷 潜龙在渊 <span style="margin-left:auto;font-size:11px;color:var(--text2)">5章</span></div>
      <div class="tc">
        <div class="tl" onclick="oC('第1章 退婚','草稿',3000)">&#128196; 第1章 退婚 <span class="bg dr">草稿</span></div>
        <div class="tl" onclick="oC('第2章 偶遇','已完成',4500)">&#128196; 第2章 偶遇 <span class="bg dn">已完成</span></div>
        <div class="tl" onclick="oC('第3章 遇险','未写',0)">&#128196; 第3章 遇险 <span class="bg em">未写</span></div>
        <div class="tl" onclick="oC('第4章 觉醒','草稿',4200)">&#128196; 第4章 觉醒 <span class="bg dr">草稿</span></div>
        <div class="tl" onclick="oC('第5章 初战','草稿',3300)">&#128196; 第5章 初战 <span class="bg dr">草稿</span></div>
      </div>
      <div class="tn" onclick="tN(this)"><span class="ar">&#9654;</span> &#128193; 第二卷 初露锋芒 <span style="margin-left:auto;font-size:11px;color:var(--text2)">5章</span></div>
      <div class="tc">
        <div class="tl" onclick="oC('第6章 龙城','草稿',3800)">&#128196; 第6章 龙城 <span class="bg dr">草稿</span></div>
        <div class="tl">&#128196; 第7章 挑战 <span class="bg em">未写</span></div>
      </div>
      <div class="tn" onclick="tN(this)"><span class="ar">&#9654;</span> &#128193; 第三卷 名动天下 <span style="margin-left:auto;font-size:11px;color:var(--text2)">5章</span></div>
      <div class="tc"><div class="tl">&#128196; 第11章 决战 <span class="bg em">未写</span></div></div>
    </div>
    <!-- 斗破苍穹 -->
    <div class="tn" onclick="tN(this)"><span class="ar">&#9654;</span> &#128214; 斗破苍穹 <span style="margin-left:auto;font-size:11px;color:var(--text2)">2卷8章</span></div>
    <div class="tc">
      <div class="tn" onclick="tN(this)"><span class="ar">&#9654;</span> &#128193; 第一卷 废柴逆袭 <span style="margin-left:auto;font-size:11px;color:var(--text2)">5章</span></div>
      <div class="tc">
        <div class="tl">&#128196; 第1章 萧炎 <span class="bg dn">已完成</span></div>
        <div class="tl">&#128196; 第2章 药老 <span class="bg dr">草稿</span></div>
      </div>
    </div>
  </div>

  <!-- 资料库 -->
  <div class="ss">
    <div class="sst">资料库</div>
    <div class="tn" onclick="tN(this)" oncontextmenu="oRelGraph();return false"><span class="ar">&#9654;</span> &#128100; 角色 (3) <span style="margin-left:auto;font-size:10px;color:var(--ac);cursor:pointer" onclick="event.stopPropagation();oRelGraph()">&#129309; 关系图</span></div>
    <div class="tc"><div class="tl">林逸 [主角]</div><div class="tl">苏雨涵 [女主]</div><div class="tl">赵天明 [反派]</div></div>
    <div class="tn" onclick="tN(this)"><span class="ar">&#9654;</span> &#9881; 设定 (2)</div>
    <div class="tc"><div class="tl">灵气复苏 [世界观]</div><div class="tl">九大境界 [战力体系]</div></div>
    <div class="tn" onclick="tN(this)"><span class="ar">&#9654;</span> &#128161; 伏笔 (1)</div>
    <div class="tc"><div class="tl">主角身世之谜</div></div>
    <div class="tn"><span class="ar">&#9654;</span> &#128278; 势力 (0)</div>
    <div class="tn"><span class="ar">&#9654;</span> &#128230; 道具 (0)</div>
    <div class="tn"><span class="ar">&#9654;</span> &#128218; 参考 (0)</div>
    <div class="tn"><span class="ar">&#9654;</span> &#129504; 记忆包</div>
  </div>

  <!-- 底部按钮 -->
  <div class="sbb">
    <button onclick="cS();oExpo()">&#128228; 导出</button>
    <button>&#128229; 导入</button>
  </div>
</div>

<!-- ====== RIGHT PANEL (Chapter Detail) ====== -->
<div class="ro" id="rO" onclick="cR()"></div>
<div class="rp" id="rP">
  <div style="display:flex;align-items:center;gap:8px;margin-bottom:16px">
    <button class="ib" onclick="cR()" style="margin-left:-8px">&#10005;</button>
    <h3 id="rT" style="font-size:15px">第1章 退婚</h3>
  </div>
  <div style="margin-bottom:12px">
    <span class="bg dr" id="rSt" style="margin-left:0">草稿</span>
    <span style="font-size:12px;color:var(--text2);margin-left:8px" id="rWc">3000 字</span>
  </div>
  <div style="font-size:12px;color:var(--text2);margin-bottom:16px;line-height:1.6"><b>梗概：</b>林逸退伍归来，在家族宴会上遭遇未婚妻当众退婚。他忍辱离开，却在巷子里救下一位神秘老者...</div>
  <div style="border-top:1px solid var(--bd);padding-top:12px">
    <div class="sti" onclick="cR()"><span class="lb">&#9998; 编辑章节</span></div>
    <div class="sti"><span class="lb">&#128221; 编辑梗概</span></div>
    <div class="sti"><span class="lb">&#128260; 改状态</span></div>
    <div class="sti"><span class="lb">&#9986; 拆分章节</span></div>
    <div class="sti"><span class="lb">&#128228; 导出此章</span></div>
    <div class="sti"><span class="lb">&#128229; 导入替换</span></div>
    <div class="sti" style="color:#dc3545"><span class="lb" style="color:#dc3545">&#128465; 删除章节</span></div>
  </div>
</div>


<!-- ====== BOTTOM SHEET ====== -->
<div class="sho" id="shO" onclick="cSh()"></div>
<div class="sh2" id="sh2">
  <div class="shh"></div>
  <div class="sgr">
    <div class="si" onclick="cSh()"><span class="ic">&#127908;</span>语音输入</div>
    <div class="si" onclick="cSh()"><span class="ic">&#128206;</span>上传文件</div>
    <div class="si" onclick="cSh();oMP()"><span class="ic">&#128218;</span>选择资料</div>
    <div class="si" onclick="cSh()"><span class="ic">&#128203;</span>选择模板</div>
    <div class="si" onclick="cSh()"><span class="ic">&#127813;</span>番茄写作</div>
    <div class="si" onclick="cSh()"><span class="ic">&#128172;</span>语音通话</div>
    <div class="si" onclick="cSh()"><span class="ic">&#128202;</span>写作统计</div>
    <div class="si" onclick="cSh()"><span class="ic">&#128269;</span>全局搜索</div>
    <div class="si" onclick="cSh();oSt()"><span class="ic">&#9881;</span>更多设置</div>
  </div>
</div>

<!-- ====== EXPORT PANEL ====== -->
<div class="expo" id="expo">
  <div class="sh">
    <button class="ib bk" onclick="cExpo()">&#8592;</button>
    <h2>导出作品</h2>
  </div>
  <div style="padding:12px 14px;font-size:13px;color:var(--text2)">选择导出格式：</div>
  <div class="exfmt" onclick="alert('导出为 ZIP 工作树包')">
    <div class="efn">&#128230; ZIP 工作树包</div>
    <div class="efd">原始文件 + 工作文件 + 记忆包，dual_track格式</div>
  </div>
  <div class="exfmt" onclick="alert('导出为 EPUB')">
    <div class="efn">&#128214; EPUB 电子书</div>
    <div class="efd">标准EPUB3格式，支持章节导航和目录</div>
  </div>
  <div class="exfmt" onclick="alert('导出为 DOCX')">
    <div class="efn">&#128196; DOCX 文档</div>
    <div class="efd">Word格式，可用WPS/Office打开编辑</div>
  </div>
  <div class="exopt"><label><input type="checkbox" checked> 包含原始备份文件</label></div>
  <div class="exopt"><label><input type="checkbox" checked> 包含记忆包</label></div>
  <div class="exopt"><label><input type="checkbox"> 仅选中章节</label></div>
  <div style="padding:16px 14px">
    <button style="width:100%;padding:14px;border-radius:12px;background:var(--ac);color:#fff;border:none;font-size:15px;font-weight:600;cursor:pointer" onclick="alert('开始导出...')">&#128228; 开始导出</button>
    <button style="width:100%;padding:12px;border-radius:12px;background:none;border:1px solid var(--bd);font-size:14px;cursor:pointer;margin-top:8px;color:var(--text)">&#128279; 分享到其他应用</button>
  </div>
</div>

<!-- ====== RELATIONSHIP GRAPH ====== -->
<div class="expo" id="relGraph">
  <div class="sh">
    <button class="ib bk" onclick="cRelGraph()">&#8592;</button>
    <h2>角色关系图</h2>
  </div>
  <div id="graphContainer" style="width:100%;height:100%;position:relative;overflow:hidden;background:var(--bg2)">
    <canvas id="graphCanvas" style="width:100%;height:100%"></canvas>
  </div>
</div>

<!-- ====== MATERIAL PICKER ====== -->
<div class="sho" id="mpO" onclick="cMP()"></div>
<div class="sh2" id="mpP" style="max-height:70vh">
  <div class="shh"></div>
  <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px">
    <span style="font-size:15px;font-weight:600">选择资料发给AI</span>
    <button style="background:var(--ac);color:#fff;border:none;border-radius:8px;padding:6px 16px;font-size:13px;cursor:pointer" onclick="confirmMP()">确定</button>
  </div>
  <div style="display:flex;gap:6px;overflow-x:auto;margin-bottom:12px" id="mpTabs">
    <div class="pill mp-tab ac" onclick="switchMPTab(0)">角色</div>
    <div class="pill mp-tab" onclick="switchMPTab(1)">设定</div>
    <div class="pill mp-tab" onclick="switchMPTab(2)">章节</div>
    <div class="pill mp-tab" onclick="switchMPTab(3)">伏笔</div>
  </div>
  <div id="mpList" style="max-height:40vh;overflow-y:auto">
    <!-- populated by JS -->
  </div>
</div>

<!-- ====== SETTINGS ====== -->
<div class="sto" id="sto">
  <div class="sth"><button class="bk" onclick="cSt()">&#8592;</button><h2>设置</h2></div>

  <div class="sts"><h3>AI 模型</h3>
    <div class="sti2" onclick="alert('跳转AI配置列表页')"><span class="lb">模型配置</span><span class="sb3">7个已配置</span><span class="ar2">&#8250;</span></div>
    <div class="sti2"><span class="lb">&#129504; 用户记忆</span><span class="sb3">记录写作风格</span><span class="ar2">&#8250;</span></div>
    <div class="sti2"><span class="lb">&#127908; 语音模型</span><span class="sb3" style="color:orange">待配置</span><span class="ar2">&#8250;</span></div>
    <div class="sti2"><span class="lb">&#10024; Skill 管理</span><span class="sb3">AI写作技巧</span><span class="ar2">&#8250;</span></div>
  </div>

  <div class="sts"><h3>番茄写作</h3>
    <div class="sti2"><span class="lb">&#129302; Agent 市场</span><span class="sb3">智能体工具</span><span class="ar2">&#8250;</span></div>
    <div class="sti2" style="cursor:default"><span class="lb">每日字数目标</span>
      <div class="wg"><button onclick="aGo(-500)">-</button><span class="nm" id="gN">3000</span><button onclick="aGo(500)">+</button></div>
    </div>
    <div class="sti2"><span class="lb">&#128202; 写作统计</span><span class="sb3">字数趋势/打卡</span><span class="ar2">&#8250;</span></div>
  </div>

  <div class="sts"><h3>外观</h3>
    <div class="sti2" style="cursor:default"><span class="lb">深色模式</span><button class="tg" id="dT" onclick="tT()"></button></div>
    <div style="padding:8px 0">
      <div style="font-size:14px;margin-bottom:8px">主题皮肤</div>
      <div class="skg">
        <div class="sk ac" style="background:#fff;border-color:var(--bd)">&#9679; 纯白</div>
        <div class="sk" style="background:#212121;color:#fff">&#9679; 暗夜</div>
        <div class="sk" style="background:#e3f2fd">&#9679; 清水蓝</div>
        <div class="sk" style="background:#fff8e1">&#9679; 暖日黄</div>
        <div class="sk" style="background:#e8f5e9">&#9679; 护眼绿</div>
        <div class="sk" style="background:#fce4ec">&#9679; 樱花粉</div>
        <div class="sk" style="background:#efebe9">&#9679; 原木</div>
        <div class="sk" style="background:#ffebee">&#9679; 中国红</div>
      </div>
    </div>
    <div class="sti2"><span class="lb">字体设置</span><span class="sb3">字号/行高</span><span class="ar2">&#8250;</span></div>
  </div>

  <div class="sts"><h3>数据管理</h3>
    <div class="sti2" onclick="alert('备份所有作品为 .zip')"><span class="lb">&#128230; 备份所有作品</span><span class="sb3">.zip压缩包</span><span class="ar2">&#8250;</span></div>
    <div class="sti2"><span class="lb">&#128260; 恢复备份</span><span class="ar2">&#8250;</span></div>
    <div class="sti2" style="color:#dc3545"><span class="lb" style="color:#dc3545">&#128465; 清空所有数据</span></div>
  </div>

  <div class="sts"><h3>其他</h3>
    <div class="sti2"><span class="lb">&#128196; 软件配置</span><span class="sb3">自定义行为</span><span class="ar2">&#8250;</span></div>
    <div class="sti2"><span class="lb">&#128227; 公告</span><span class="sb3">免费AI模型说明</span><span class="ar2">&#8250;</span></div>
    <div class="sti2"><span class="lb">&#9432; 关于</span><span class="sb3">网文写作IDE · 完全单机</span><span class="ar2">&#8250;</span></div>
  </div>
  <div style="height:40px"></div>
</div>

</div><!-- end phone -->

<script>
var models=['GLM-4.7-Flash','GLM-4.6V-Flash','GLM-4.1V-Thinking','GPT-4o','Claude Sonnet','DeepSeek V3','本地 Ollama'];

// Sidebar
function tS(){document.getElementById('sB').classList.toggle('open');document.getElementById('sO').classList.toggle('open')}
function cS(){document.getElementById('sB').classList.remove('open');document.getElementById('sO').classList.remove('open')}

// Model
function tM(){document.getElementById('mD').classList.toggle('open')}
function cM(){document.getElementById('mD').classList.remove('open')}
function sM(el,i){document.querySelectorAll('.mi').forEach(function(e){e.classList.remove('ac')});el.classList.add('ac');document.getElementById('mC').textContent=models[i];cM()}

// Theme
var dk=false;
function tT(){dk=!dk;document.documentElement.setAttribute('data-theme',dk?'dark':'');document.getElementById('tB').innerHTML=dk?'&#9728;':'&#127769;';document.getElementById('dT').classList.toggle('on',dk)}

// Bottom sheet
function tSh(){document.getElementById('sh2').classList.toggle('open');document.getElementById('shO').classList.toggle('open')}
function cSh(){document.getElementById('sh2').classList.remove('open');document.getElementById('shO').classList.remove('open')}

// Agent/Skill selector
function oASel(){document.getElementById('asel').classList.toggle('open')}
function cASel(){document.getElementById('asel').classList.remove('open')}

// Chapter detail
function oC(n,st,wc){cS();document.getElementById('rT').textContent=n;document.getElementById('rSt').textContent=st;document.getElementById('rWc').textContent=wc+' 字';document.getElementById('rP').classList.add('open');document.getElementById('rO').classList.add('open')}
function cR(){document.getElementById('rP').classList.remove('open');document.getElementById('rO').classList.remove('open')}

// Export
function oExpo(){document.getElementById('expo').classList.add('open')}
function cExpo(){document.getElementById('expo').classList.remove('open')}

// Settings
function oSt(){document.getElementById('sto').classList.add('open')}
function cSt(){document.getElementById('sto').classList.remove('open')}

// Tree toggle
function tN(el){el.classList.toggle('open');var c=el.nextElementSibling;if(c&&c.classList.contains('tc'))c.classList.toggle('open');var a=el.querySelector('.ar');if(a)a.classList.toggle('op')}

// Word goal
var gl=3000;function aGo(d){gl=Math.max(500,Math.min(20000,gl+d));document.getElementById('gN').textContent=gl}

// Voice
var voiceOn=false;function toggleVoice(){voiceOn=!voiceOn;document.getElementById('micBtn').style.background=voiceOn?'#dc3545':'';document.getElementById('micBtn').style.color=voiceOn?'#fff':''}

// Send message
function sMs(){
  var inp=document.getElementById('inp');var t=inp.value.trim();if(!t)return;
  addMsg(t,'u');inp.value='';aG(inp);cASel();
  setTimeout(function(){addTyp()},500);
  setTimeout(function(){rmTyp();addMsg('正在为你构思...这是一个初步方案，需要调整吗？','a')},2000);
}
function sP(t){document.getElementById('inp').value=t;sMs()}
function newSession(){document.getElementById('inp').value='';cS()}

function addMsg(t,r){
  var d=document.createElement('div');d.className='msg '+r;
  d.innerHTML='<div class="av">'+(r==='u'?'&#128100;':'AI')+'</div><div class="bub">'+t+'</div>';
  var c=document.getElementById('cA');c.insertBefore(d,document.getElementById('cE'));c.scrollTop=c.scrollHeight;
}
function addTyp(){var d=document.createElement('div');d.className='msg a';d.id='typM';d.innerHTML='<div class="av">AI</div><div class="bub"><div class="typ"><span></span><span></span><span></span></div></div>';var c=document.getElementById('cA');c.insertBefore(d,document.getElementById('cE'));c.scrollTop=c.scrollHeight}
function rmTyp(){var e=document.getElementById('typM');if(e)e.remove()}
function aG(el){el.style.height='auto';el.style.height=Math.min(el.scrollHeight,100)+'px'}

// Close model dropdown on outside click
document.addEventListener('click',function(e){if(!e.target.closest('.topbar')&&!e.target.closest('.md'))document.getElementById('mD').classList.remove('open')});

// ====== RELATIONSHIP GRAPH ======
var graphChars=[
  {id:'c1',name:'林逸',role:'主角',color:'#4a90d9',x:150,y:120},
  {id:'c2',name:'苏雨涵',role:'女主',color:'#e91e8c',x:280,y:80},
  {id:'c3',name:'赵天明',role:'反派',color:'#e74c3c',x:220,y:250},
  {id:'c4',name:'老者',role:'师父',color:'#27ae60',x:80,y:220},
  {id:'c5',name:'萧炎',role:'配角',color:'#95a5a6',x:350,y:180}
];
var graphRels=[
  {from:'c1',to:'c2',type:'恋人'},
  {from:'c1',to:'c3',type:'敌人'},
  {from:'c4',to:'c1',type:'师徒'},
  {from:'c1',to:'c5',type:'同门'}
];
var selNode=null,dragNode=null,dragOff={x:0,y:0};

function oRelGraph(){cS();document.getElementById('relGraph').classList.add('open');setTimeout(drawGraph,100)}
function cRelGraph(){document.getElementById('relGraph').classList.remove('open')}

function drawGraph(){
  var cv=document.getElementById('graphCanvas');
  var ct=cv.getContext('2d');
  cv.width=cv.parentElement.clientWidth;cv.height=cv.parentElement.clientHeight;
  ct.clearRect(0,0,cv.width,cv.height);
  // draw edges
  graphRels.forEach(function(r){
    var f=graphChars.find(function(c){return c.id===r.from});
    var t=graphChars.find(function(c){return c.id===r.to});
    if(!f||!t)return;
    ct.beginPath();ct.moveTo(f.x,f.y);ct.lineTo(t.x,t.y);
    if(r.type==='敌人'){ct.setLineDash([6,4])}else if(r.type==='恋人'){ct.setLineDash([2,4])}else{ct.setLineDash([])}
    ct.strokeStyle=dk?'#666':'#ccc';ct.lineWidth=2;ct.stroke();ct.setLineDash([]);
    // arrow
    var dx=t.x-f.x,dy=t.y-f.y,d=Math.sqrt(dx*dx+dy*dy);
    var ax=t.x-dx/d*30,ay=t.y-dy/d*30;
    ct.beginPath();ct.moveTo(ax+dy/d*5,ay-dx/d*5);ct.lineTo(ax-dy/d*5,ay+dx/d*5);ct.lineTo(t.x-dx/d*20,t.y-dy/d*20);ct.closePath();
    ct.fillStyle=dk?'#666':'#aaa';ct.fill();
    // label
    var mx=(f.x+t.x)/2,my=(f.y+t.y)/2;
    ct.font='11px system-ui';var tw=ct.measureText(r.type).width;
    ct.fillStyle=dk?'#333':'#fff';ct.fillRect(mx-tw/2-6,my-9,tw+12,18);
    ct.strokeStyle=dk?'#555':'#ddd';ct.strokeRect(mx-tw/2-6,my-9,tw+12,18);
    ct.fillStyle=dk?'#eee':'#333';ct.textAlign='center';ct.textBaseline='middle';ct.fillText(r.type,mx,my);
  });
  // draw nodes
  graphChars.forEach(function(c){
    ct.beginPath();ct.arc(c.x,c.y,28,0,Math.PI*2);
    ct.fillStyle=c.color;ct.fill();
    if(selNode===c.id){ct.strokeStyle='#fff';ct.lineWidth=3;ct.stroke()}
    ct.fillStyle='#fff';ct.font='bold 16px system-ui';ct.textAlign='center';ct.textBaseline='middle';
    ct.fillText(c.name.charAt(0),c.x,c.y);
    ct.fillStyle=dk?'#eee':'#333';ct.font='12px system-ui';ct.fillText(c.name,c.x,c.y+40);
  });
}

function graphMouseDown(e){
  var r=e.target.getBoundingClientRect();
  var mx=e.clientX-r.left,my=e.clientY-r.top;
  for(var i=graphChars.length-1;i>=0;i--){
    var c=graphChars[i];
    if(Math.hypot(c.x-mx,c.y-my)<30){
      dragNode=c;dragOff={x:mx-c.x,y:my-c.y};
      if(selNode===null){selNode=c.id}
      else if(selNode!==c.id){
        var rel=prompt('输入关系类型（如：师徒/敌人/恋人/父子/同门）：');
        if(rel){graphRels.push({from:selNode,to:c.id,type:rel});selNode=null}
        else{selNode=null}
      }else{selNode=null}
      drawGraph();return;
    }
  }
  selNode=null;drawGraph();
}
function graphMouseMove(e){
  if(!dragNode)return;
  var r=e.target.getBoundingClientRect();
  dragNode.x=e.clientX-r.left-dragOff.x;
  dragNode.y=e.clientY-r.top-dragOff.y;
  drawGraph();
}
function graphMouseUp(){dragNode=null}

// init canvas events after DOM ready
setTimeout(function(){
  var cv=document.getElementById('graphCanvas');
  if(cv){
    cv.addEventListener('mousedown',graphMouseDown);
    cv.addEventListener('mousemove',graphMouseMove);
    cv.addEventListener('mouseup',graphMouseUp);
    cv.addEventListener('touchstart',function(e){e.preventDefault();var t=e.touches[0];graphMouseDown({clientX:t.clientX,clientY:t.clientY,target:cv})});
    cv.addEventListener('touchmove',function(e){e.preventDefault();var t=e.touches[0];graphMouseMove({clientX:t.clientX,clientY:t.clientY,target:cv})});
    cv.addEventListener('touchend',graphMouseUp);
  }
},200);

// ====== MATERIAL PICKER ======
var mpData=[
  [{n:'林逸',d:'主角，退伍特种兵，性格坚毅'},{n:'苏雨涵',d:'女主，集团千金，外柔内刚'},{n:'赵天明',d:'反派，商业巨头，野心勃勃'}],
  [{n:'灵气复苏',d:'灵气复苏后世界进入修仙时代'},{n:'九大境界',d:'炼气/筑基/金丹/元婴/化神/渡劫/大乘/仙帝/道祖'}],
  [{n:'第1章 退婚',d:'林逸退伍归来遭遇退婚'},{n:'第2章 偶遇',d:'救下老者获得修炼功法'},{n:'第3章 觉醒',d:'远古血脉首次觉醒'}],
  [{n:'主角身世之谜',d:'林逸的真实身份与远古血脉有关'}]
];
var mpTab=0,mpSel=new Set();

function oMP(){cSh();mpSel.clear();mpTab=0;renderMP();document.getElementById('mpP').classList.add('open');document.getElementById('mpO').classList.add('open')}
function cMP(){document.getElementById('mpP').classList.remove('open');document.getElementById('mpO').classList.remove('open')}
function switchMPTab(t){mpTab=t;document.querySelectorAll('.mp-tab').forEach(function(el,i){el.classList.toggle('ac',i===t)});renderMP()}
function renderMP(){
  var list=document.getElementById('mpList');list.innerHTML='';
  mpData[mpTab].forEach(function(item,i){
    var id=mpTab+'_'+i;
    var d=document.createElement('div');d.className='mp-item';
    d.innerHTML='<input type="checkbox" '+(mpSel.has(id)?'checked':'')+' onchange="toggleMP(\''+id+'\')"><div><div style="font-weight:500">'+item.n+'</div><div class="mp-preview">'+item.d+'</div></div>';
    list.appendChild(d);
  });
}
function toggleMP(id){if(mpSel.has(id))mpSel.delete(id);else mpSel.add(id);renderMP()}
function confirmMP(){
  if(mpSel.size===0){cMP();return}
  var ctx='[选择的资料上下文]\n';
  mpSel.forEach(function(id){var p=id.split('_');var item=mpData[parseInt(p[0])][parseInt(p[1])];ctx+='\n## '+item.n+'\n'+item.d+'\n'});
  ctx+='\n---请基于以上资料回答---\n';
  var inp=document.getElementById('inp');inp.value=ctx+'\n'+inp.value;aG(inp);cMP();
}
</script>
</body>
</html>"""

with open(out, 'w', encoding='utf-8') as f:
    f.write(HTML)
print(f'Done: {os.path.getsize(out)} bytes')
