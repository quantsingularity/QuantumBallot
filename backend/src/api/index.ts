import express from "express";
import cors from "cors";
const corsOptions = require("../config/coreOptions");
// <--- Middleware --->

const app_api = express();

app_api.use(express.json());
app_api.use(express.urlencoded({ extended: false }));
app_api.use(cors(corsOptions));

module.exports = function (blockchain: any, allNodes: any) {
  const redirectRoute = (text: string) => require(text)(blockchain, allNodes);

  // <--- API ROUTE END-POINTS --->
  app_api.use("/blockchain", redirectRoute("./routes/blockchain.route"));
  app_api.use("/committee", require("./routes/committee.route"));

  return app_api;
};
