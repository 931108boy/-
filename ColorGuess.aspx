
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ColorGuess.aspx.cs" Inherits="ColorGuess" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
      <title>猜顏色遊戲</title>
      <link rel="icon" type="image/png" href="https://family35.com/wp-content/uploads/2018/04/1024px-Farbkreis_Itten_1961.svg_.png" />
      <style>
        body {
          margin: 0;
          font-family: sans-serif;
          background-color: #f0f0f0;
          overflow-x: hidden;
        }
        #overlay {
          position: fixed;
          top: 0; left: 0;
          width: 100%; height: 100%;
          background: rgba(0, 0, 0, 0.5);
          display: flex;
          justify-content: center;
          align-items: center;
          z-index: 10;
        }
        #promptBox {
          background: white;
          padding: 20px;
          border-radius: 10px;
          text-align: center;
          box-shadow: 0 0 10px rgba(0,0,0,0.3);
          min-width: 300px;
        }
        #promptText {
          margin-bottom: 20px;
          white-space: pre-line;
        }
        .selectCountBtn, #continueBtn {
          margin: 5px;
          padding: 8px 16px;
          border: none;
          border-radius: 4px;
          background-color: #2196F3;
          color: white;
          cursor: pointer;
        }
        #continueBtn {
          background-color: #4CAF50;
        }
        #gameArea {
          display: none;
          flex-direction: column;
          align-items: center;
          text-align: center;
          width: 100%;
        }
        .slots {
          display: flex;
          margin: 20px 0;
          flex-wrap: wrap;
          justify-content: center;
        }
        .slot {
          width: 60px;
          height: 60px;
          margin: 0 10px;
          border: 2px solid #ccc;
          border-radius: 50%;
          background-color: white;
        }
        .buttons {
          display: flex;
          flex-wrap: wrap;
          justify-content: center;
          align-items: center;
          gap: 10px;
          margin-bottom: 20px;
        }
        .colorBtn {
          width: 60px;
          height: 60px;
          border: none;
          border-radius: 50%;
          cursor: pointer;
          flex-shrink: 0;
        }
        #undoBtn {
          background: none;
          border: none;
          font-size: 24px;
          cursor: pointer;
          display: none;
          margin-right: 10px;
        }
        #topBackBtn {
          position: absolute;
          top: 10px;
          left: 10px;
          background: none;
          border: none;
          font-size: 16px;
          cursor: pointer;
          display: none;
        }
        #result {
          position: absolute;
          bottom: 20px;
          right: 20px;
          background-color: rgba(0,0,0,0.7);
          color: white;
          padding: 10px;
          border-radius: 8px;
          font-size: 14px;
          display: none;
          max-width: 90vw;
        }
        #gameRoot {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            min-height: 100vh;
            position: relative;
        }

        @media (max-width: 600px) {
          .slot {
            width: 44px;
            height: 44px;
            margin: 5px;
          }
          .colorBtn {
            width: 48px;
            height: 48px;
          }
          #result {
            font-size: 12px;
            padding: 6px;
          }
          #undoBtn {
            font-size: 20px;
          }
          #topBackBtn {
            font-size: 14px;
          }

        }
      </style>
    </head>
    <body>
      <!-- 伺服器用的 <form> -->
      <form id="form1" runat="server">
        <!-- 若未來要加資料庫功能，可在這裡放控制項 -->
      </form>

       <div id="userInfoBar" style="
          position: fixed;
          top: 35px;
          right: 35px;
          font-size: 20px;
          display: none;
          z-index: 20;
          font-family: sans-serif;
        ">
          <span id="userDisplay" style="font-weight: bold;"></span>
          <button onclick="logout()" style="
            margin-left: 10px;
            background: none;
            border: none;
            color: #2196F3;
            text-decoration: underline;
            cursor: pointer;
            font-size: 18px;
            font-weight: normal;
          ">登出</button>
        </div>

      <!-- 🟢 遊戲放在 form 之外 -->
      <div id="gameRoot">

          <button id="topBackBtn" onclick="resetForNewGame()">返回選擇</button>

          <div id="overlay">
            <div id="promptBox">
              <div id="promptText">請輸入你的名字：</div>
                <div style="display: flex; justify-content: center; align-items: center; gap: 10px; margin: 10px 0;">
                  <input type="text" id="userNameInput" placeholder="請輸入你的名字"
                    style="padding:8px; font-size:16px; width:200px; border-radius:4px; border:1px solid #ccc;"
                    onkeydown="if(event.key === 'Enter') submitUserName()" />
                  <button class="selectCountBtn" onclick="submitUserName()">開始遊戲</button>
                </div>




              <div id="countButtons" style="display: none;">
                <button class="selectCountBtn" onclick="initGame(3)">3 個</button>
                <button class="selectCountBtn" onclick="initGame(4)">4 個</button>
                <button class="selectCountBtn" onclick="initGame(5)">5 個</button>
                <button class="selectCountBtn" onclick="initGame(6)">6 個</button>
                <button class="selectCountBtn" onclick="initGame(7)">7 個</button>
              </div>
              <div id="endButtons" style="display: none;">
                <button id="continueBtn" onclick="resetForNewGame()">重新開始</button>
              </div>
            </div>
          </div>

          <div id="gameArea">
            <div class="slots" id="slots"></div>
            <div class="buttons">
              <button id="undoBtn" onclick="undoColor()">⟵</button>
              <button class="colorBtn" style="background-color:red" onclick="chooseColor('R')"></button>
              <button class="colorBtn" style="background-color:orange" onclick="chooseColor('O')"></button>
              <button class="colorBtn" style="background-color:green" onclick="chooseColor('G')"></button>
              <button class="colorBtn" style="background-color:blue" onclick="chooseColor('B')"></button>
              <button class="colorBtn" style="background-color:purple" onclick="chooseColor('P')"></button>
              <button class="colorBtn" style="background-color:black" onclick="chooseColor('K')"></button>
              <button class="colorBtn" style="background-color:yellow" onclick="chooseColor('Y')"></button>
            </div>
          </div>

          <div id="result"></div>
      </div>

        <!-- 左下角按鈕列 -->
        <div id="bottomButtonBar" style="
          position: fixed;
          bottom: 20px;
          left: 20px;
          display: flex;
          gap: 10px;
          z-index: 20;
        ">

          <!-- 答題記錄按鈕 -->
          <button id="historyBtn" onclick="toggleHistory()" style="
            padding: 8px 14px;
            font-size: 14px;
            background-color: #2196F3;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            display: none;
          ">答題記錄</button>

          <!-- 排行榜按鈕 -->
          <button id="rankBtn" onclick="toggleRank()" style="
            padding: 8px 14px;
            font-size: 14px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            display: none;
          ">排行榜</button>

        </div>

        <!-- 彈出記錄視窗 -->
        <div id="historyBox" style="
            display: none;
            position: fixed;
            bottom: 70px;
            left: 20px;
            width: 280px;
            max-height: 250px;
            overflow-y: auto;
            background-color: white;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-shadow: 0 0 8px rgba(0,0,0,0.2);
            padding: 10px;
            font-size: 14px;
            display: none;
            z-index: 20;
        ">
            <div id="historyContent">尚無紀錄</div>
        </div>

        <!-- 🟢 排行榜視窗 -->
        <div id="rankBox" style="
          position: fixed;
          bottom: 70px;
          left: 20px;
          width: 320px;
          max-height: 300px;
          overflow-y: auto;
          background-color: white;
          border: 1px solid #ccc;
          border-radius: 8px;
          box-shadow: 0 0 8px rgba(0,0,0,0.2);
          padding: 10px;
          font-size: 14px;
          display: none;
          z-index: 20;
        ">
          <div style="font-weight:bold; margin-bottom: 6px;">🏆 排行榜</div>
          <div id="rankContent">尚無紀錄</div>
        </div>
      <script>
        let historyRecords = [];
        const colors = "ROGBPKY";
        const colorMap = {
          R: "red", O: "orange", G: "green", B: "blue",
          P: "purple", K: "black", Y: "yellow"
        };
        const colorNameMap = {
          R: "紅", O: "橙", G: "綠", B: "藍",
          P: "紫", K: "黑", Y: "黃"
        };

        let answer = [];
        let currentGuess = [];
        let n = 0;

        function initGame(count) {
          n = count;
          answer = [];
          currentGuess = [];
          for (let i = 0; i < n; i++) {
            answer.push(colors[Math.floor(Math.random() * colors.length)]);
          }
          document.getElementById("overlay").style.display = "none";
          document.getElementById("gameArea").style.display = "flex";
          document.getElementById("result").innerText = `你好: ${window.userName}，歡迎來到猜顏色遊戲，請點選顏色按鈕。`;
          document.getElementById("result").style.display = "block";
          document.getElementById("undoBtn").style.display = "inline-block";
          document.getElementById("topBackBtn").style.display = "inline-block";
          document.getElementById("historyBtn").style.display = "block";
          document.getElementById("historyBox").style.display = "none";
          document.getElementById("rankBtn").style.display = "none";
          document.getElementById("rankBox").style.display = "none";
          drawSlots();
        }

        function drawSlots() {
          const slotsContainer = document.getElementById("slots");
          slotsContainer.innerHTML = "";
          for (let i = 0; i < n; i++) {
            const div = document.createElement("div");
            div.className = "slot";
            slotsContainer.appendChild(div);
          }
        }

        function chooseColor(colorCode) {
          if (currentGuess.length >= n) return;
          currentGuess.push(colorCode);
          const slots = document.querySelectorAll(".slot");
          slots[currentGuess.length - 1].style.backgroundColor = colorMap[colorCode];

          if (currentGuess.length === n) checkAnswer();
        }

        function undoColor() {
          if (currentGuess.length === 0) return;
          const slots = document.querySelectorAll(".slot");
          currentGuess.pop();
          slots[currentGuess.length].style.backgroundColor = "white";
        }

        function checkAnswer() {
            let correct = 0;
            for (let i = 0; i < n; i++) {
                if (currentGuess[i] === answer[i]) correct++;
            }

            const guessStr = currentGuess.map(c => colorNameMap[c]).join("");
            document.getElementById("result").innerText = `顏色：${guessStr}，答對${correct}個`;

            // 記錄這次的猜測
            historyRecords.push({
                guess: guessStr,
                correct: correct
            });
            updateHistoryBox();

            if (correct === n) {
                setTimeout(() => {
                    currentGuess = [];
                    const answerStr = answer.map(c => colorNameMap[c]).join("");
                    submitGameRecord(window.userName, n, historyRecords.length);
                    document.getElementById("promptText").innerText = `恭喜你全猜對了！正確答案是：${answerStr}。\n要再玩一次嗎？`;
                    document.getElementById("countButtons").style.display = "none";
                    document.getElementById("endButtons").style.display = "block";
                    document.getElementById("overlay").style.display = "flex";
                    document.getElementById("gameArea").style.display = "none";
                    document.getElementById("result").style.display = "none";
                    document.getElementById("undoBtn").style.display = "none";
                    document.getElementById("topBackBtn").style.display = "none";
                    document.getElementById("rankBtn").style.display = "block";
                    document.getElementById("historyBtn").style.display = "none";
                    document.getElementById("historyBox").style.display = "none";
                    loadRankData();
                }, 1000);
            } else {
                document.getElementById("result").style.border = "2px solid red";
                setTimeout(() => {
                    currentGuess = [];
                    resetSlots();
                    document.getElementById("result").style.border = "none";
                }, 800);
            }
        }

        function resetSlots() {
          const slots = document.querySelectorAll(".slot");
          slots.forEach(slot => slot.style.backgroundColor = "white");
        }

        function submitUserName() {
            const nameInput = document.getElementById("userNameInput");
            const name = nameInput.value.trim();
            if (name === "") {
                alert("請先輸入名字！");
                nameInput.focus();
                return;
            }

            window.userName = name;

            // 顯示右上角名稱與登出
            document.getElementById("userDisplay").innerText = `${name}`;
            document.getElementById("userInfoBar").style.display = "block";

            // 顯示選擇顏色選單
            document.getElementById("promptText").innerText = `你好，${name}！請選擇要猜幾個顏色？`;
            nameInput.style.display = "none";
            document.querySelector("button.selectCountBtn").style.display = "none";
            document.getElementById("countButtons").style.display = "block";
        }


        function resetForNewGame() {
            if (window.userName) {
                document.getElementById("promptText").innerText = `歡迎回來，${window.userName}！請選擇要猜幾個顏色？`;
                document.getElementById("userNameInput").style.display = "none";
                document.querySelector("button.selectCountBtn").style.display = "none";
                document.getElementById("countButtons").style.display = "block";
                document.getElementById("userInfoBar").style.display = "block"; // 顯示右上角
                document.getElementById("userDisplay").innerText = `${window.userName}`;
            } else {
                document.getElementById("promptText").innerText = "請輸入你的名字：";
                document.getElementById("userNameInput").style.display = "inline-block";
                document.querySelector("button.selectCountBtn").style.display = "inline-block";
                document.getElementById("countButtons").style.display = "none";
                document.getElementById("userInfoBar").style.display = "none";
            }

            document.getElementById("endButtons").style.display = "none";
            document.getElementById("overlay").style.display = "flex";
            document.getElementById("topBackBtn").style.display = "none";
            document.getElementById("gameArea").style.display = "none";
            document.getElementById("result").style.display = "none";
            document.getElementById("result").innerText = "";
            document.getElementById("slots").innerHTML = "";
            currentGuess = [];
            answer = [];
            historyRecords = [];
            updateHistoryBox();
            document.getElementById("historyBtn").style.display = "none";
            document.getElementById("historyBox").style.display = "none";
            document.getElementById("rankBtn").style.display = "block";
            document.getElementById("rankBox").style.display = "none";

            loadRankData();
         }

        function logout() {
            window.userName = null;
            document.getElementById("userInfoBar").style.display = "none";
            document.getElementById("userDisplay").innerText = "";
            document.getElementById("userNameInput").value = "";
            document.getElementById("rankBtn").style.display = "block";
            document.getElementById("rankBox").style.display = "none";
            resetForNewGame();
         }

        function toggleHistory() {
            const box = document.getElementById("historyBox");
            box.style.display = box.style.display === "none" ? "block" : "none";
        }

        function toggleRank() {
            const box = document.getElementById("rankBox");
            const showing = box.style.display === "block";
            box.style.display = showing ? "none" : "block";
            if (!showing) loadRankData(); // 開啟排行榜時才重新載入資料
        }

        window.onload = function () {
            document.getElementById("rankBtn").style.display = "block";
         };

        function submitGameRecord(userName, colorCount, attempts) {
            fetch("ColorGuess.aspx/SaveGameRecord", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ userName, colorCount, attempts })
            })
                .then(res => res.json())
                .then(data => console.log("✅ 資料已寫入：", data.d))
                .catch(err => console.error("❌ 寫入失敗：", err));
        }

        function loadRankData() {
            fetch("ColorGuess.aspx/GetRankData", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                // ✅ 這裡是關鍵修改！
                body: JSON.stringify({ input: { userName: window.userName || "你" } })
            })
                .then(res => res.json())
                .then(data => {
                    const result = data.d;
                    console.log("📊 排行榜結果：", result);

                    const difficultyLevels = [3, 4, 5, 6, 7];
                    let html = "";

                    difficultyLevels.forEach(level => {
                        html += `<div style="margin-bottom:6px;">
        <div>🎯 ${level} 色：</div>
        <div style="margin-left:10px;">
        👤 你的紀錄：${result.mine[level] ?? "尚無"} 次<br>
        🌍 所有人最少：${result.all[level] ?? "尚無"} 次
        </div>
    </div>`;
                    });

                    document.getElementById("rankContent").innerHTML = html;
                })
                .catch(err => {
                    console.error("❌ 讀取排行榜失敗：", err);
                    document.getElementById("rankContent").innerText = "⚠️ 無法載入排行榜資料";
                });
         }

          function updateHistoryBox() {
              const content = document.getElementById("historyContent");
              if (historyRecords.length === 0) {
                  content.innerText = "尚無紀錄";
                  return;
              }

              content.innerHTML = historyRecords.map((r, i) =>
                  `第 ${i + 1} 次：猜「${r.guess}」，答對 ${r.correct} 個`
              ).join("<br>");
          }
        </script>
    </body>
</html>
