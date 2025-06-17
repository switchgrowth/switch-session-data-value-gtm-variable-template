___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Switch - Session Data Value",
  "description": "Provides the ability to retrieve a value from a Switch Session Data cookie.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "cookieName",
    "displayName": "Cookie Name",
    "simpleValueType": true,
    "help": "Case insensitive - A unique name that this cookie will be stored under. Either \"Switch\" or the organizations name \"Google\".",
    "defaultValue": "SwitchTempData",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "cookieKey",
    "displayName": "Cookie Key to Retrieve",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Require only the necessary GTM APIs
const log = require('logToConsole');
const getCookieValues = require('getCookieValues');
const fromBase64 = require('fromBase64');
const JSON = require('JSON');

// Get user-provided data from the template fields
const cookieName = "__Secure-" + (data.cookieName || 'SwitchTempData');
const keyToRetrieve = data.cookieKey;

// Check 1: A key must be provided.
if (!keyToRetrieve) {
  log('Error: No "Cookie Key" was specified in the variable settings.');
  return;
}

// Check 2: Get the cookie and ensure it's not null or empty.
const cookieValuesArr = getCookieValues(cookieName);
if (!cookieValuesArr || cookieValuesArr.length === 0) {
  log('Info: Cookie "' + cookieName + '" not found or is empty.');
  return;
}

// Check 3: Decode the cookie and ensure the result is not empty.
const decodedCookie = fromBase64(cookieValuesArr.toString());
if (!decodedCookie) {
  log('Info: Decoded cookie "' + cookieName + '" is empty.');
  return;
}

// Check 4: Prevent JSON.parse errors by checking if it looks like an object.
if (decodedCookie.trim().indexOf('{') !== 0) {
    log('Error: Decoded cookie value is not a valid JSON object. Value was:', decodedCookie);
    return;
}

// Now it's much safer to parse the string.
const parsedCookie = JSON.parse(decodedCookie);

// First, try for a fast, exact-match (case-sensitive).
if (parsedCookie.hasOwnProperty(keyToRetrieve)) {
  return parsedCookie[keyToRetrieve];
}

// THE FINAL FIX: If no exact match, perform a case-insensitive "contains" search using indexOf().
const keyToRetrieveLower = keyToRetrieve.toLowerCase();
for (const key in parsedCookie) {
  if (parsedCookie.hasOwnProperty(key) && key.toLowerCase().indexOf(keyToRetrieveLower) !== -1) {
    // If the cookie key contains the search key (case-insensitive), return its value.
    return parsedCookie[key];
  }
}

// If no key was ever found, return undefined.
log('Info: Key "' + keyToRetrieve + '" not found in cookie "' + cookieName + '".');
return;


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Requires a Cookie Name & Key Value
  code: |-
    const mockData = {
      cookieKey: "",
      cookieName: ""
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(undefined);
- name: Runs the Call Window Event
  code: |-
    const mockData = {
      cookieKey: "email",
      cookieName: "SwitchTempData"
    };

    mock('callInWindow', "email@test.com");

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    assertApi("callInWindow").wasCalled();

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo("email@test.com");


___NOTES___

Created on 6/16/2025, 5:39:19 PM


