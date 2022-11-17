import React, {useState, useEffect, useCallback} from 'react';
import {GiftedChat} from 'react-native-gifted-chat';
import {Text, View, NativeModule, Button} from 'react-native';
import {NativeModules, NativeEventEmitter} from 'react-native';
import {launchImageLibrary} from 'react-native-image-picker';
import {decode as atob, encode as btoa} from 'base-64';

const {GenesysMessenger} = NativeModules;
const MessageEvents = new NativeEventEmitter(NativeModules.GenesysMessenger);

const Chats = () => {
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    setMessages();
  }, []);

  const onSend = useCallback((messages = []) => {
    console.log(messages);
    // setMessages(previousMessages =>
    //   GiftedChat.append(previousMessages, messages),
    // );
    GenesysMessenger.sendMessage(messages[0].text);
  }, []);

  useEffect(() => {
    GenesysMessenger.setupGenesis();
    MessageEvents.addListener('onMessage', res => {
      if (res && res.message) {
        if (res.type === 'inbound') {
          addInboundMessage(res.message);
        } else {
          addOutboundMessage(res.message);
        }
      }
    });
    return () => {};
  }, []);

  const addInboundMessage = text => {
    if (text) {
      setMessages(previousMessages =>
        GiftedChat.append(previousMessages, [
          {
            _id: Date.now().toString(),
            text: text,
            createdAt: new Date(),
            user: {
              _id: 1,
            },
          },
        ]),
      );
    }
  };

  const addOutboundMessage = text => {
    setMessages(previousMessages =>
      GiftedChat.append(previousMessages, [
        {
          _id: Date.now().toString(),

          text: text,
          createdAt: new Date(),
          user: {
            _id: 2,
          },
        },
      ]),
    );
    // setMessages(previousMessages =>
    //   GiftedChat.append(previousMessages, messages),
    // );
  };

  function _base64ToArrayBuffer(base64) {
    var binary_string = atob(base64);
    var len = binary_string.length;
    var bytes = new Uint8Array(len);
    for (var i = 0; i < len; i++) {
      bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes;
  }

  const sendImage = async () => {
    const result = await launchImageLibrary({
      mediaType: 'photo',
      includeBase64: true,
    });
    GenesysMessenger.uploadAttachment(result.assets[0].base64);
  };

  return (
    <View style={{flex: 1}}>
      <Button title="Send image" onPress={sendImage} />
      <GiftedChat
        messages={messages}
        onSend={messages => onSend(messages)}
        user={{
          _id: 1,
        }}
      />
    </View>
  );
};

export default Chats;
