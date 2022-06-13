db.getCollection("students").aggregate([
  { $unwind: "$enrolled_in" },
  {
      "$project": {
          "candidate_to": {
              "$filter": {
                  input: "$candidate_to",
                  as: "candidature",
                  cond: { $eq: ["$$candidature.program.code", "$enrolled_in.program.code"] }
              }
          },
          "id": 1
      }
  },
  { $unwind: "$candidate_to" },
  {
      $group: {
          "_id": {
              "id": "$id",
              "code": "$candidate_to.program.code",
              "designation": "$candidate_to.program.designation",
          },
          "n_applications": { $sum: 1 }
      }
  },
  { $sort: { "n_applications": -1 } }

])