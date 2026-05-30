# -*- coding: utf-8 -*-
import os

out = r'D:\AI\preview\index.html'

def w(s):
    return s

css = """
*{margin:0;padding:0;box-sizing:border-box}
:root{
  --bg:#fff;--bg2:#f7f7f8;--bg3:#ececf1;--text:#1a1a1a;--text2:#6b6b6b;
  --bubble-user:#f0f0f0;--bubble-ai:#e8f4fd;--accent:#10a37f;--accent2:#0d8c6e;
  --sidebar:#fff;--overlay:rgba(0,0,0,.4);--border:#e5e5e5;
  --shadow:0 2px 12px rgba(0,0,0,.08);--radius:16px;
}
[data-theme=dark]{
  --bg:#212121;--bg2:#2f2f2f;--bg3:#3e3e3e;--text:#ececec;--text2:#9a9a9a;
  --bubble-user:#303030;--bubble-ai:#1a3a4a;--accent:#10a37f;--accent2:#0d8c6e;
  --sidebar:#1e1e1e;--overlay:rgba(0,0,0,.6);--border:#444;
}
body{font-family:system-ui,-apple-system,sans-serif;background:var(--bg2);color:var(--text);height:100vh;overflow:hidden;display:flex;justify-content:center}
.phone{width:375px;height:100vh;background:var(--bg);display:flex;flex-direction:column;position:relative;overflow:hidden}
.topbar{display:flex;align-items:center;padding:10px 14px;background:var(--bg);border-bottom:1px solid var(--border);min-height:52px;z-index:10}
.topbar .icon-btn{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;background:none;border:none;font-size:18px;cursor:pointer;color:var(--text)}
.topbar .title-box{flex:1;text-align:center}
.topbar .title{font-weight:600;font-size:15px;cursor:pointer}
.topbar .model-chip{font-size:11px;background:var(--bg2);border:1px solid var(--border);border-radius:8px;padding:2px 8px;color:var(--text2);display:inline-block;margin-top:2px;cursor:pointer}
.chat{flex:1;overflow-y:auto;padding:16px 14px 130px;scroll-behavior:smooth}
.msg{display:flex;gap:8px;margin-bottom:14px;animation:fadeIn .3s}
.msg.user{flex-direction:row-reverse}
.msg .avatar{width:28px;height:28px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0}
.msg.user .avatar{background:#6366f1;color:#fff}
.msg.ai .avatar{background:var(--accent);color:#fff}
.msg .bubble{max-width:80%;padding:10px 14px;border-radius:var(--radius);font-size:14px;line-height:1.6}
.msg.user .bubble{background:var(--bubble-user);border-bottom-right-radius:4px}
.msg.ai .bubble{background:var(--bubble-ai);border-bottom-left-radius:4px}
.typing{display:flex;gap:4px;padding:6px 0}
.typing span{width:6px;height:6px;background:var(--text2);border-radius:50%;animation:bounce .6s infinite alternate}
.typing span:nth-child(2){animation-delay:.2s}
.typing span:nth-child(3){animation-delay:.4s}
@keyframes bounce{to{opacity:.3;transform:translateY(-4px)}}
@keyframes fadeIn{from{opacity:0;transform:translateY(6px)}to{opacity:1;transform:none}}
.pills{display:flex;gap:8px;padding:10px 14px;overflow-x:auto;-webkit-overflow-scrolling:touch;position:absolute;bottom:56px;left:0;right:0;background:var(--bg);border-top:1px solid var(--border)}
.pills::-webkit-scrollbar{display:none}
.pill{flex-shrink:0;padding:6px 14px;border-radius:20px;font-size:13px;background:var(--bg2);border:1px solid var(--border);cursor:pointer;white-space:nowrap}
.pill:active{background:var(--accent);color:#fff}
.input-area{display:flex;align-items:flex-end;gap:8px;padding:10px 14px;background:var(--bg);position:absolute;bottom:0;left:0;right:0;z-index:5;border-top:1px solid var(--border)}
.input-area textarea{flex:1;border:1px solid var(--border);border-radius:20px;padding:8px 14px;font-size:14px;background:var(--bg2);color:var(--text);resize:none;outline:none;max-height:120px;font-family:inherit}
.input-area .send-btn{width:36px;height:36px;border-radius:50%;background:var(--accent);border:none;color:#fff;font-size:16px;cursor:pointer;display:flex;align-items:center;justify-content:center}
.input-area .extra-btn{width:36px;height:36px;border-radius:50%;background:none;border:1px solid var(--border);font-size:16px;cursor:pointer;display:flex;align-items:center;justify-content:center;color:var(--text2)}
.model-dropdown{position:absolute;top:52px;left:50%;transform:translateX(-50%);width:280px;background:var(--sidebar);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow);z-index:20;padding:8px;display:none}
.model-dropdown.open{display:block;animation:fadeIn .2s}
.model-item{padding:10px 12px;border-radius:10px;cursor:pointer;font-size:14px;display:flex;align-items:center;gap:8px}
.model-item:hover,.model-item.active{background:var(--bg2)}
.model-item.active::after{content:"\\2713";margin-left:auto;color:var(--accent);font-weight:bold}
.model-divider{height:1px;background:var(--border);margin:6px 0}
.sidebar-overlay{position:absolute;inset:0;background:var(--overlay);z-index:30;opacity:0;pointer-events:none;transition:opacity .3s}
.sidebar-overlay.open{opacity:1;pointer-events:auto}
.sidebar{position:absolute;top:0;left:-280px;width:280px;height:100%;background:var(--sidebar);z-index:31;transition:left .3s;overflow-y:auto;border-right:1px solid var(--border)}
.sidebar.open{left:0}
.sidebar-header{padding:14px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--border)}
.sidebar-header .new-chat{flex:1;padding:10px;border-radius:10px;border:1px solid var(--border);background:none;font-size:14px;cursor:pointer;text-align:left;color:var(--text)}
.sidebar-section{padding:4px 10px}
.sidebar-section-title{font-size:12px;font-weight:600;color:var(--text2);padding:10px 4px 4px}
.chat-item{padding:10px 12px;border-radius:10px;cursor:pointer;font-size:13px;color:var(--text);line-height:1.4}
.chat-item:hover{background:var(--bg2)}
.chat-item .time{font-size:11px;color:var(--text2);display:block;margin-top:2px}
.tree-node{display:flex;align-items:center;gap:6px;padding:7px 10px;cursor:pointer;font-size:13px;border-radius:6px;color:var(--text)}
.tree-node:hover{background:var(--bg2)}
.tree-node .arrow{width:16px;text-align:center;font-size:10px;color:var(--text2);transition:transform .2s;flex-shrink:0}
.tree-node .arrow.open{transform:rotate(90deg)}
.tree-children{padding-left:16px;display:none}
.tree-children.open{display:block}
.tree-leaf{display:flex;align-items:center;gap:6px;padding:5px 10px 5px 26px;font-size:13px;cursor:pointer;border-radius:6px;color:var(--text2)}
.tree-leaf:hover{background:var(--bg2)}
.badge{font-size:10px;padding:1px 6px;border-radius:4px;margin-left:auto}
.badge.draft{background:#fff3cd;color:#856404}
.badge.done{background:#d4edda;color:#155724}
.badge.empty{background:#e2e3e5;color:#383d41}
.badge.blue{background:#cce5ff;color:#004085}
.sidebar-bottom{padding:12px 14px;border-top:1px solid var(--border);display:flex;gap:10px;position:sticky;bottom:0;background:var(--sidebar)}
.sidebar-bottom button{flex:1;padding:10px;border-radius:10px;border:1px solid var(--border);background:none;font-size:13px;cursor:pointer;color:var(--text)}
.right-panel{position:absolute;top:0;right:-320px;width:300px;height:100%;background:var(--sidebar);z-index:31;transition:right .3s;overflow-y:auto;border-left:1px solid var(--border);padding:16px}
.right-panel.open{right:0}
.right-overlay{position:absolute;inset:0;background:var(--overlay);z-index:30;opacity:0;pointer-events:none;transition:opacity .3s}
.right-overlay.open{opacity:1;pointer-events:auto}
.sheet-overlay{position:absolute;inset:0;background:var(--overlay);z-index:30;opacity:0;pointer-events:none;transition:opacity .3s}
.sheet-overlay.open{opacity:1;pointer-events:auto}
.sheet{position:absolute;bottom:-420px;left:0;right:0;background:var(--sidebar);border-radius:16px 16px 0 0;z-index:31;transition:bottom .3s;padding:16px 16px 24px}
.sheet.open{bottom:0}
.sheet-handle{width:36px;height:4px;background:var(--border);border-radius:2px;margin:0 auto 16px}
.sheet-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.sheet-item{padding:14px;border-radius:12px;background:var(--bg2);cursor:pointer;text-align:center;font-size:13px}
.sheet-item:active{background:var(--accent);color:#fff}
.sheet-item .icon{font-size:24px;display:block;margin-bottom:6px}
.settings-overlay{position:absolute;inset:0;background:var(--bg);z-index:32;transform:translateX(100%);transition:transform .3s;overflow-y:auto}
.settings-overlay.open{transform:none}
.settings-header{display:flex;align-items:center;padding:14px;gap:10px;border-bottom:1px solid var(--border);position:sticky;top:0;background:var(--bg);z-index:2}
.settings-header .back{width:36px;height:36px;border:none;background:none;font-size:18px;cursor:pointer;color:var(--text)}
.settings-header h2{font-size:16px;font-weight:600}
.settings-section{padding:0 14px}
.settings-section h3{font-size:12px;color:var(--text2);padding:16px 0 6px;font-weight:600;text-transform:uppercase}
.settings-item{display:flex;align-items:center;padding:14px 0;border-bottom:1px solid var(--border);cursor:pointer;gap:12px}
.settings-item .label{flex:1;font-size:14px}
.settings-item .sub{font-size:12px;color:var(--text2)}
.settings-item .arrow-r{color:var(--text2)}
.toggle{width:44px;height:26px;border-radius:13px;background:var(--border);position:relative;cursor:pointer;border:none;transition:background .2s;flex-shrink:0}
.toggle.on{background:var(--accent)}
.toggle::after{content:"";position:absolute;width:22px;height:22px;border-radius:50%;background:#fff;top:2px;left:2px;transition:transform .2s}
.toggle.on::after{transform:translateX(18px)}
.skin-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;padding:8px 0}
.skin-card{padding:12px 6px;border-radius:10px;text-align:center;cursor:pointer;border:2px solid transparent;font-size:11px}
.skin-card.active{border-color:var(--accent)}
.word-goal{display:flex;align-items:center;gap:12px;padding:10px 0}
.word-goal button{width:30px;height:30px;border-radius:50%;border:1px solid var(--border);background:none;font-size:16px;cursor:pointer;color:var(--text)}
.word-goal .num{font-size:18px;font-weight:bold;width:80px;text-align:center}
</style>
</head>
<body>
<div class="phone" id="app">
"""

html_content = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>网文写作IDE</title>
<style>
""" + css.split("<style>\n",1)[1].split("</style>")[0] + """</style>
</head>
<body>
<div class="phone" id="app">

<!-- TOP BAR -->
<div class="topbar">
  <button class="icon-btn" onclick="toggleSidebar()">&#9776;</button>
  <div class="title-box">
    <div class="title" onclick="toggleModel()">网文写作IDE</div>
    <div class="model-chip" onclick="toggleModel()" id="modelChip">GLM-4.7-Flash</div>
  </div>
  <button class="icon-btn" onclick="toggleTheme()" id="themeBtn">&#127769;</button>
  <button class="icon-btn" onclick="openSettings()">&#128100;</button>
</div>

<!-- MODEL DROPDOWN -->
<div class="model-dropdown" id="modelDrop">
  <div class="model-item active" onclick="selectModel(this,'GLM-4.7-Flash')">GLM-4.7-Flash <span style="font-size:11px;color:var(--text2)">(内置免费)</span></div>
  <div class="model-item" onclick="selectModel(this,'GLM-4.6V-Flash')">GLM-4.6V-Flash <span style="font-size:11px;color:var(--text2)">(多模态)</span></div>
  <div class="model-item" onclick="selectModel(this,'GLM-4.1V-Thinking')">GLM-4.1V-Thinking <span style="font-size:11px;color:var(--text2)">(思考版)</span></div>
  <div class="model-divider"></div>
  <div class="model-item" onclick="selectModel(this,'GPT-4o')">GPT-4o</div>
  <div class="model-item" onclick="selectModel(this,'Claude Sonnet')">Claude Sonnet</div>
  <div class="model-item" onclick="selectModel(this,'DeepSeek V3')">DeepSeek V3</div>
  <div class="model-divider"></div>
  <div class="model-item" style="color:var(--accent);font-size:13px">&#9881; 管理模型 &gt;</div>
</div>

<!-- CHAT AREA -->
<div class="chat" id="chatArea">
  <div class="msg user">
    <div class="avatar">&#128100;</div>
    <div class="bubble">帮我写一部都市修仙小说的大纲，主角是退伍特种兵</div>
  </div>
  <div class="msg ai">
    <div class="avatar">AI</div>
    <div class="bubble"><b>《都市修仙传》大纲草案</b><br><br><b>第一卷：觉醒</b><br>主角林逸，退伍特种兵，在一次意外中激活体内远古血脉，踏入修仙之路...<br><br><b>第二卷：初露锋芒</b><br>林逸在龙城崭露头角，同时面对来自修仙界的挑战...<br><br>需要我详细展开某一卷吗？</div>
  </div>
  <div class="msg user">
    <div class="avatar">&#128100;</div>
    <div class="bubble">展开第一卷，写出5章的章纲</div>
  </div>
  <div class="msg ai">
    <div class="avatar">AI</div>
    <div class="bubble"><b>第一卷「觉醒」章纲</b><br><br><b>第1章 退婚</b><br>林逸退伍归来，遭遇未婚妻退婚羞辱...<br><b>第2章 偶遇</b><br>在山中救下受伤老者，获得修炼功法...<br><b>第3章 觉醒</b><br>修炼功法，体内远古血脉首次觉醒...<br><b>第4章 初战</b><br>击退上门挑衅的黑道势力...<br><b>第5章 龙城</b><br>前往龙城，新的征程开始...<br><br><span style="font-size:12px;color:var(--text2)">&#128161; 已保存到资料库「大纲」分类</span></div>
  </div>
  <div id="chatEnd"></div>
</div>

<!-- QUICK PILLS -->
<div class="pills" id="pills">
  <div class="pill" onclick="sendPill('续写下一段')">续写</div>
  <div class="pill" onclick="sendPill('润色当前段落')">润色</div>
  <div class="pill" onclick="sendPill('生成完整大纲')">生成大纲</div>
  <div class="pill" onclick="sendPill('分析角色关系')">角色分析</div>
  <div class="pill" onclick="sendPill('校对全文')">校对</div>
  <div class="pill" onclick="sendPill('全文审查')">全文审查</div>
</div>

<!-- INPUT BAR -->
<div class="input-area">
  <button class="extra-btn" onclick="toggleSheet()">+</button>
  <textarea id="input" rows="1" placeholder="输入消息，或选择下方操作..." oninput="autoGrow(this)"></textarea>
  <button class="send-btn" onclick="sendMsg()">&#9654;</button>
</div>

<!-- LEFT SIDEBAR -->
<div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>
<div class="sidebar" id="sidebar">
  <div class="sidebar-header">
    <button class="new-chat">+ 新会话</button>
  </div>
  <div class="sidebar-section">
    <div class="sidebar-section-title">历史会话</div>
    <div class="chat-item">都市神医开篇讨论<span class="time">今天 14:30</span></div>
    <div class="chat-item">大纲优化建议<span class="time">昨天 20:15</span></div>
    <div class="chat-item">角色关系梳理<span class="time">5月28日</span></div>
  </div>
  <div class="sidebar-section">
    <div class="sidebar-section-title">作品</div>
    <!-- 都市神医 -->
    <div class="tree-node" onclick="toggleTree(this)">
      <span class="arrow">&#9654;</span> &#128214; 都市神医 <span style="margin-left:auto;font-size:11px;color:var(--text2)">3卷 15章</span>
    </div>
    <div class="tree-children">
      <div class="tree-node" onclick="toggleTree(this)">
        <span class="arrow">&#9654;</span> &#128193; 第一卷 潜龙在渊 <span style="margin-left:auto;font-size:11px;color:var(--text2)">5章</span>
      </div>
      <div class="tree-children">
        <div class="tree-leaf" onclick="openChapter('第1章 退婚')">&#128196; 第1章 退婚 <span class="badge draft">草稿</span></div>
        <div class="tree-leaf" onclick="openChapter('第2章 偶遇')">&#128196; 第2章 偶遇 <span class="badge done">已完成</span></div>
        <div class="tree-leaf" onclick="openChapter('第3章 遇险')">&#128196; 第3章 遇险 <span class="badge empty">未写</span></div>
        <div class="tree-leaf" onclick="openChapter('第4章 觉醒')">&#128196; 第4章 觉醒 <span class="badge draft">草稿</span></div>
        <div class="tree-leaf" onclick="openChapter('第5章 初战')">&#128196; 第5章 初战 <span class="badge draft">草稿</span></div>
      </div>
      <div class="tree-node" onclick="toggleTree(this)">
        <span class="arrow">&#9654;</span> &#128193; 第二卷 初露锋芒 <span style="margin-left:auto;font-size:11px;color:var(--text2)">5章</span>
      </div>
      <div class="tree-children">
        <div class="tree-leaf">&#128196; 第6章 龙城 <span class="badge draft">草稿</span></div>
        <div class="tree-leaf">&#128196; 第7章 挑战 <span class="badge empty">未写</span></div>
      </div>
      <div class="tree-node" onclick="toggleTree(this)">
        <span class="arrow">&#9654;</span> &#128193; 第三卷 名动天下 <span style="margin-left:auto;font-size:11px;color:var(--text2)">5章</span>
      </div>
      <div class="tree-children">
        <div class="tree-leaf">&#128196; 第11章 决战 <span class="badge empty">未写</span></div>
      </div>
    </div>
    <!-- 斗破苍穹 -->
    <div class="tree-node" onclick="toggleTree(this)">
      <span class="arrow">&#9654;</span> &#128214; 斗破苍穹 <span style="margin-left:auto;font-size:11px;color:var(--text2)">2卷 8章</span>
    </div>
    <div class="tree-children">
      <div class="tree-node" onclick="toggleTree(this)">
        <span class="arrow">&#9654;</span> &#128193; 第一卷 废柴逆袭 <span style="margin-left:auto;font-size:11px;color:var(--text2)">5章</span>
      </div>
      <div class="tree-children">
        <div class="tree-leaf">&#128196; 第1章 萧炎 <span class="badge done">已完成</span></div>
        <div class="tree-leaf">&#128196; 第2章 药老 <span class="badge draft">草稿</span></div>
      </div>
    </div>
  </div>
  <div class="sidebar-section">
    <div class="sidebar-section-title">资料库</div>
    <div class="tree-node" onclick="toggleTree(this)">
      <span class="arrow">&#9654;</span> &#128100; 角色 (3)
    </div>
    <div class="tree-children">
      <div class="tree-leaf">林逸 [主角]</div>
      <div class="tree-leaf">苏雨涵 [女主]</div>
      <div class="tree-leaf">赵天明 [反派]</div>
    </div>
    <div class="tree-node" onclick="toggleTree(this)">
      <span class="arrow">&#9654;</span> &#9881; 设定 (2)
    </div>
    <div class="tree-children">
      <div class="tree-leaf">灵气复苏 [世界观]</div>
      <div class="tree-leaf">九大境界 [战力体系]</div>
    </div>
    <div class="tree-node" onclick="toggleTree(this)">
      <span class="arrow">&#9654;</span> &#128161; 伏笔 (1)
    </div>
    <div class="tree-children">
      <div class="tree-leaf">主角身世之谜</div>
    </div>
    <div class="tree-node"><span class="arrow">&#9654;</span> &#128278; 势力 (0)</div>
    <div class="tree-node"><span class="arrow">&#9654;</span> &#128230; 道具 (0)</div>
    <div class="tree-node"><span class="arrow">&#9654;</span> &#128218; 参考 (0)</div>
    <div class="tree-node"><span class="arrow">&#9654;</span> &#129504; 记忆包</div>
  </div>
  <div class="sidebar-bottom">
    <button>&#128230; 备份</button>
    <button>&#128229; 导入</button>
  </div>
</div>

<!-- RIGHT PANEL -->
<div class="right-overlay" id="rightOverlay" onclick="closeRight()"></div>
<div class="right-panel" id="rightPanel">
  <div style="display:flex;align-items:center;gap:8px;margin-bottom:16px">
    <button class="icon-btn" onclick="closeRight()" style="margin-left:-8px">&#10005;</button>
    <h3 id="rightTitle" style="font-size:15px">第1章 退婚</h3>
  </div>
  <div style="margin-bottom:12px">
    <span class="badge draft" style="margin-left:0">草稿</span>
    <span style="font-size:12px;color:var(--text2);margin-left:8px">3000 字</span>
  </div>
  <div style="font-size:12px;color:var(--text2);margin-bottom:16px;line-height:1.6">
    <b>梗概：</b>林逸退伍归来，在家族宴会上遭遇未婚妻当众退婚。他忍辱离开，却在巷子里救下一位神秘老者...
  </div>
  <div style="border-top:1px solid var(--border);padding-top:12px">
    <div class="settings-item" style="padding:10px 0">&#9998; 编辑章节</div>
    <div class="settings-item" style="padding:10px 0">&#128221; 编辑梗概</div>
    <div class="settings-item" style="padding:10px 0">&#128260; 改状态</div>
    <div class="settings-item" style="padding:10px 0">&#9986; 拆分章节</div>
    <div class="settings-item" style="padding:10px 0;color:#dc3545">&#128465; 删除章节</div>
  </div>
</div>

<!-- BOTTOM SHEET -->
<div class="sheet-overlay" id="sheetOverlay" onclick="closeSheet()"></div>
<div class="sheet" id="sheet">
  <div class="sheet-handle"></div>
  <div class="sheet-grid">
    <div class="sheet-item"><span class="icon">&#127908;</span>语音输入</div>
    <div class="sheet-item"><span class="icon">&#128206;</span>上传文件</div>
    <div class="sheet-item"><span class="icon">&#128203;</span>选择模板</div>
    <div class="sheet-item"><span class="icon">&#127813;</span>番茄写作</div>
    <div class="sheet-item"><span class="icon">&#128172;</span>语音通话</div>
    <div class="sheet-item"><span class="icon">&#128202;</span>写作统计</div>
    <div class="sheet-item"><span class="icon">&#128269;</span>全局搜索</div>
    <div class="sheet-item"><span class="icon">&#9881;</span>更多设置</div>
  </div>
</div>

<!-- SETTINGS PANEL -->
<div class="settings-overlay" id="settingsPanel">
  <div class="settings-header">
    <button class="back" onclick="closeSettings()">&#8592;</button>
    <h2>设置</h2>
  </div>
  <div class="settings-section">
    <h3>AI 模型配置</h3>
    <div class="settings-item"><span class="label">当前模型</span><span class="sub">GLM-4.7-Flash</span><span class="arrow-r">&#8250;</span></div>
    <div class="settings-item"><span class="label">模型列表</span><span class="sub">7个已配置</span><span class="arrow-r">&#8250;</span></div>
  </div>
  <div class="settings-section">
    <h3>AI 写作</h3>
    <div class="settings-item"><span class="label">&#129504; 用户记忆</span><span class="sub">记录写作风格和偏好</span><span class="arrow-r">&#8250;</span></div>
    <div class="settings-item"><span class="label">&#127908; 语音模型</span><span class="sub" style="color:orange">待配置</span><span class="arrow-r">&#8250;</span></div>
    <div class="settings-item"><span class="label">&#10024; Skill</span><span class="sub">管理AI写作技巧</span><span class="arrow-r">&#8250;</span></div>
  </div>
  <div class="settings-section">
    <h3>番茄写作</h3>
    <div class="settings-item"><span class="label">Agent</span><span class="sub">智能体市场</span><span class="arrow-r">&#8250;</span></div>
    <div class="settings-item" style="cursor:default">
      <span class="label">每日字数目标</span>
      <div class="word-goal">
        <button onclick="adjustGoal(-500)">-</button>
        <span class="num" id="goalNum">3000</span>
        <button onclick="adjustGoal(500)">+</button>
      </div>
    </div>
    <div class="settings-item"><span class="label">写作统计</span><span class="sub">字数趋势和打卡</span><span class="arrow-r">&#8250;</span></div>
  </div>
  <div class="settings-section">
    <h3>外观</h3>
    <div class="settings-item" style="cursor:default">
      <span class="label">深色模式</span>
      <button class="toggle" id="darkToggle" onclick="toggleTheme()"></button>
    </div>
    <div style="padding:8px 0">
      <div style="font-size:14px;margin-bottom:8px">主题皮肤</div>
      <div class="skin-grid">
        <div class="skin-card active" style="background:#fff;border-color:var(--border)">&#9679; 纯白</div>
        <div class="skin-card" style="background:#212121;color:#fff">&#9679; 暗夜</div>
        <div class="skin-card" style="background:#e3f2fd">&#9679; 清水蓝</div>
        <div class="skin-card" style="background:#fff8e1">&#9679; 暖日黄</div>
        <div class="skin-card" style="background:#e8f5e9">&#9679; 护眼绿</div>
        <div class="skin-card" style="background:#fce4ec">&#9679; 樱花粉</div>
        <div class="skin-card" style="background:#efebe9">&#9679; 原木</div>
        <div class="skin-card" style="background:#ffebee">&#9679; 中国红</div>
      </div>
    </div>
    <div class="settings-item"><span class="label">字体设置</span><span class="sub">字号/行高</span><span class="arrow-r">&#8250;</span></div>
  </div>
  <div class="settings-section">
    <h3>数据管理</h3>
    <div class="settings-item"><span class="label">&#128230; 备份所有作品</span><span class="sub">导出 .zip</span><span class="arrow-r">&#8250;</span></div>
    <div class="settings-item"><span class="label">&#128260; 恢复备份</span><span class="arrow-r">&#8250;</span></div>
    <div class="settings-item" style="color:#dc3545"><span class="label" style="color:#dc3545">&#128465; 清空所有数据</span></div>
  </div>
  <div class="settings-section">
    <h3>其他</h3>
    <div class="settings-item"><span class="label">软件配置</span><span class="arrow-r">&#8250;</span></div>
    <div class="settings-item"><span class="label">公告</span><span class="sub">免费AI模型使用说明</span><span class="arrow-r">&#8250;</span></div>
    <div class="settings-item"><span class="label">关于</span><span class="sub">网文写作IDE &#183; 完全单机运行</span><span class="arrow-r">&#8250;</span></div>
  </div>
  <div style="height:40px"></div>
</div>

</div><!-- end phone -->

<script>
// Sidebar
function toggleSidebar(){document.getElementById('sidebar').classList.toggle('open');document.getElementById('sidebarOverlay').classList.toggle('open')}
function closeSidebar(){document.getElementById('sidebar').classList.remove('open');document.getElementById('sidebarOverlay').classList.remove('open')}
// Model
function toggleModel(){document.getElementById('modelDrop').classList.toggle('open')}
function selectModel(el,name){document.querySelectorAll('.model-item').forEach(i=>i.classList.remove('active'));el.classList.add('active');document.getElementById('modelChip').textContent=name;document.getElementById('modelDrop').classList.remove('open')}
// Theme
let dark=false;
function toggleTheme(){dark=!dark;document.documentElement.setAttribute('data-theme',dark?'dark':'');document.getElementById('themeBtn').innerHTML=dark?'&#9728;':'&#127769;';var t=document.getElementById('darkToggle');t.classList.toggle('on',dark)}
// Sheet
function toggleSheet(){document.getElementById('sheet').classList.toggle('open');document.getElementById('sheetOverlay').classList.toggle('open')}
function closeSheet(){document.getElementById('sheet').classList.remove('open');document.getElementById('sheetOverlay').classList.remove('open')}
// Right panel
function openChapter(name){closeSidebar();document.getElementById('rightTitle').textContent=name;document.getElementById('rightPanel').classList.add('open');document.getElementById('rightOverlay').classList.add('open')}
function closeRight(){document.getElementById('rightPanel').classList.remove('open');document.getElementById('rightOverlay').classList.remove('open')}
// Settings
function openSettings(){document.getElementById('settingsPanel').classList.add('open')}
function closeSettings(){document.getElementById('settingsPanel').classList.remove('open')}
// Tree
function toggleTree(el){el.classList.toggle('open');var c=el.nextElementSibling;if(c&&c.classList.contains('tree-children')){c.classList.toggle('open')};var a=el.querySelector('.arrow');if(a)a.classList.toggle('open')}
// Word goal
let goal=3000;
function adjustGoal(d){goal=Math.max(500,Math.min(20000,goal+d));document.getElementById('goalNum').textContent=goal}
// Send
function sendMsg(){
  var inp=document.getElementById('input');
  var t=inp.value.trim();if(!t)return;
  addMsg(t,'user');inp.value='';autoGrow(inp);
  setTimeout(function(){addTyping()},500);
  setTimeout(function(){removeTyping();addMsg('正在为你构思，请稍等...\\n\\n这是一个初步方案，需要我调整吗？','ai')},2000);
}
function sendPill(t){document.getElementById('input').value=t;sendMsg()}
function addMsg(t,role){
  var d=document.createElement('div');d.className='msg '+role;
  d.innerHTML='<div class="avatar">'+(role==='user'?'&#128100;':'AI')+'</div><div class="bubble">'+t.replace(/\\n/g,'<br>')+'</div>';
  var chat=document.getElementById('chatArea');chat.insertBefore(d,document.getElementById('chatEnd'));chat.scrollTop=chat.scrollHeight;
}
function addTyping(){var d=document.createElement('div');d.className='msg ai';d.id='typingMsg';d.innerHTML='<div class="avatar">AI</div><div class="bubble"><div class="typing"><span></span><span></span><span></span></div></div>';var c=document.getElementById('chatArea');c.insertBefore(d,document.getElementById('chatEnd'));c.scrollTop=c.scrollHeight}
function removeTyping(){var e=document.getElementById('typingMsg');if(e)e.remove()}
// Auto-grow textarea
function autoGrow(el){el.style.height='auto';el.style.height=Math.min(el.scrollHeight,120)+'px'}
// Close dropdown on outside click
document.addEventListener('click',function(e){if(!e.target.closest('.topbar')&&!e.target.closest('.model-dropdown'))document.getElementById('modelDrop').classList.remove('open')});
</script>
</body>
</html>"""

with open(out, 'w', encoding='utf-8') as f:
    f.write(html_content)
print(f'Done: {os.path.getsize(out)} bytes')
