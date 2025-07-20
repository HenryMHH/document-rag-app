## direct response
direct_response = {
  id: "chatcmpl-Bv1Z7BShhT8yAhfailvScNK4YraGY",
  choices: [
    {
      finish_reason: :stop,
      index: 0,
      logprobs: nil,
      message: {
        content: "I don’t have access to real-time data. You can check the current weather by using a weather website or app like Weather.com, AccuWeather, or a voice assistant like Siri or Google Assistant. If you tell me your location, I can help guide you on where to look!",
        refusal: nil,
        role: :assistant,
        annotations: []
      }
    }
  ],
  created: 1_752_930_413,
  model: "gpt-4.1-mini-2025-04-14",
  object: :"chat.completion",
  service_tier: :default,
  system_fingerprint: nil,
  usage: {
    completion_tokens: 58,
    prompt_tokens: 13,
    total_tokens: 71,
    completion_tokens_details: {
      accepted_prediction_tokens: 0,
      audio_tokens: 0,
      reasoning_tokens: 0,
      rejected_prediction_tokens: 0
    },
    prompt_tokens_details: {
      audio_tokens: 0,
      cached_tokens: 0
    }
  }
}

## tool call response
tool_call_response = {
  id: "chatcmpl-Bv1jAuMIxmQScmh0Ls8FIrEdEmWk8",
  choices: [
    {
      finish_reason: :tool_calls,
      index: 0,
      logprobs: nil,
      message: {
        content: nil,
        refusal: nil,
        role: :assistant,
        annotations: [],
        tool_calls: [
          {
            id: "call_w5fIfIJJsqfuvM4dqoQY1TrL",
            function: {
              arguments: "{\"location\":\"Taiwan\"}",
              name: "get_weather"
            },
            type: :function
          }
        ]
      }
    }
  ],
  created: 1_752_931_036,
  model: "gpt-4.1-mini-2025-04-14",
  object: :"chat.completion",
  service_tier: :default,
  system_fingerprint: nil,
  usage: {
    completion_tokens: 15,
    prompt_tokens: 65,
    total_tokens: 80,
    completion_tokens_details: {
      accepted_prediction_tokens: 0,
      audio_tokens: 0,
      reasoning_tokens: 0,
      rejected_prediction_tokens: 0
    },
    prompt_tokens_details: {
      audio_tokens: 0,
      cached_tokens: 0
    }
  }
}
