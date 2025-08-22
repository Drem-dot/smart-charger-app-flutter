const functions = require("firebase-functions");
const {google} = require("googleapis");
const path = require("path"); // Thêm thư viện 'path'

// --- THAY ĐỔI: Sử dụng đường dẫn tuyệt đối để đảm bảo tìm thấy file ---
// eslint-disable-next-line max-len
// __dirname là một biến toàn cục trong Node.js, trỏ đến thư mục chứa file đang chạy
const serviceAccountPath = path.join(__dirname, "service-account.json");

exports.submitReport = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "POST");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.set("Access-Control-Max-Age", "3600");
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  try {
    const {
      stationId, stationName, stationAddress,
      reason, details, phoneNumber, timestamp,
    } = req.body;

    // --- THAY ĐỔI: Cung cấp đường dẫn file key một cách tường minh ---
    const auth = new google.auth.GoogleAuth({
      keyFile: serviceAccountPath,
      scopes: ["https://www.googleapis.com/auth/spreadsheets"],
    });

    const client = await auth.getClient();
    const sheets = google.sheets({version: "v4", auth: client});

    // eslint-disable-next-line max-len
    const spreadsheetId = "110y81WBJTjyAgTmSJoDOE0hG3_mmDifkaRfQt9sPe6g"; // Nhớ thay ID của sếp

    const newRow = [[
      timestamp, stationId, stationName, stationAddress,
      reason, details, phoneNumber, "Mới",
    ]];

    await sheets.spreadsheets.values.append({
      spreadsheetId,
      range: "Sheet1!A:H", // Nhớ kiểm tra lại tên trang tính
      valueInputOption: "USER_ENTERED",
      resource: {values: newRow},
    });

    return res.status(200).json({message: "Báo cáo đã được gửi thành công!"});
  } catch (error) {
    console.error("Lỗi khi ghi vào Google Sheet:", error);
    return res.status(500).json({error: "Không thể xử lý báo cáo."});
  }
});
