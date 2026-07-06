import cors from "cors";
import express from "express";

const app = express();
const port = Number(process.env.BACKEND_PORT ?? 8080);
const greeting = "Привіт Світ!";

app.use(cors());
app.use(express.json());

app.get("/api/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.get("/api/hello", (_req, res) => {
  res.json({ message: greeting });
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Backend is listening on port ${port}`);
});
