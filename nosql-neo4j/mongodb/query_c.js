db.getCollection("students").aggregate([
  {
      "$project": {
          "enrolled_in": {
              "$filter": {
                  input: "$enrolled_in",
                  as: "enrollment",
                  cond: { $ifNull: ["$$enrollment.conclusion_year", false] }
              }
          },
          "candidate_to": 1,
          "id": 1,
      }
  },
  { $unwind: "$enrolled_in" },
  {
      "$project": {
          "candidate_to": {
              "$filter": {
                  input: "$candidate_to",
                  as: "candidature",
                  cond: {
                      $and: [
                          { $eq: ["$$candidature.program.code", "$enrolled_in.program.code"] },
                          { $ifNull: ["$$candidature.average", false] },
                          { $gt: ["$enrolled_in.final_average", "$$candidature.average"] }
                      ]
                  }
              }
          },
          "nr": "$enrolled_in.nr",
          "id": 1
      }
  },
  { $unwind: "$candidate_to" },
  {
      "$project": {
          "id": 1,
          "nr": 1
      }
  }
])