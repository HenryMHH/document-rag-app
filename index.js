const chat_history = [
  {
    role: 'user',

    content: 'recommend a legal document for house rental',
  },

  {
    content: null,

    refusal: null,

    role: 'assistant',

    annotations: [],

    tool_calls: [
      {
        id: 'call_uLn3CBjn2SPPbgxWee54QFis',

        function: {
          arguments:
            '{"search_message":"legal document for house rental"}',

          name: 'search_document',
        },

        type: 'function',
      },
    ],
  },

  {
    role: 'tool',

    tool_call_id: 'call_uLn3CBjn2SPPbgxWee54QFis',

    name: 'search_document',

    content: 'Lease Rental Agreement',
  },

  {
    content:
      'I recommend using a "Lease Rental Agreement" for house rental. This document outlines the terms and conditions between the landlord and tenant, including rent amount, duration, responsibilities, and other important details to protect both parties. If you need, I can help you draft a basic template or provide key clauses to include.',

    refusal: null,

    role: 'assistant',

    annotations: [],
  },
];
