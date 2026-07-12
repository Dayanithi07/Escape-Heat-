"use client";

import { useState, useRef, useEffect } from "react";
import { Send, Bot, Loader2 } from "lucide-react";
import { initialMessages, quickPrompts, getMockResponse } from "@/lib/mock-data/chat";
import { generateId, sleep, formatTime } from "@/lib/utils";
import type { ChatMessage } from "@/types";

// We use a simple markdown renderer without importing remark
function MessageContent({ content }: { content: string }) {
  return (
    <div className="prose prose-sm max-w-none text-inherit">
      {content.split("\n").map((line, i) => {
        if (line.startsWith("**") && line.endsWith("**")) {
          return <p key={i} className="font-bold mt-1">{line.slice(2, -2)}</p>;
        }
        if (line.startsWith("- ")) {
          return <p key={i} className="ml-3">• {line.slice(2)}</p>;
        }
        if (line === "") return <br key={i} />;
        // Handle inline bold
        const parts = line.split(/(\*\*[^*]+\*\*)/g);
        return (
          <p key={i}>
            {parts.map((part, j) =>
              part.startsWith("**") && part.endsWith("**") ? (
                <strong key={j}>{part.slice(2, -2)}</strong>
              ) : (
                part
              )
            )}
          </p>
        );
      })}
    </div>
  );
}

export default function ChatWindow() {
  const [messages, setMessages] = useState<ChatMessage[]>(initialMessages);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const sendMessage = async (text: string) => {
    if (!text.trim() || isLoading) return;

    const userMsg: ChatMessage = {
      id: generateId(),
      role: "user",
      content: text.trim(),
      timestamp: new Date().toISOString(),
    };

    setMessages((prev) => [...prev, userMsg]);
    setInput("");
    setIsLoading(true);

    // Typing indicator
    const typingId = generateId();
    setMessages((prev) => [
      ...prev,
      { id: typingId, role: "assistant", content: "", timestamp: new Date().toISOString(), isTyping: true },
    ]);

    // Simulate response latency
    await sleep(1200 + Math.random() * 800);

    const response = getMockResponse(text);

    setMessages((prev) =>
      prev.map((m) =>
        m.id === typingId
          ? { ...m, content: response, isTyping: false }
          : m
      )
    );
    setIsLoading(false);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    sendMessage(input);
  };

  return (
    <div className="flex flex-col h-full">
      {/* Messages */}
      <div
        ref={scrollRef}
        className="flex-1 overflow-y-auto px-4 py-4 space-y-4 min-h-0"
      >
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex gap-3 animate-slide-up ${
              msg.role === "user" ? "justify-end" : "justify-start"
            }`}
          >
            {msg.role === "assistant" && (
              <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center flex-shrink-0 mt-1">
                <Bot className="w-4 h-4 text-white" />
              </div>
            )}

            <div
              className={`max-w-[85%] px-4 py-3 text-sm leading-relaxed ${
                msg.role === "user"
                  ? "chat-bubble-user"
                  : "chat-bubble-ai"
              }`}
            >
              {msg.isTyping ? (
                <div className="flex items-center gap-1.5 py-1">
                  <span className="w-2 h-2 rounded-full bg-orange-500 animate-bounce" style={{ animationDelay: "0ms" }} />
                  <span className="w-2 h-2 rounded-full bg-orange-500 animate-bounce" style={{ animationDelay: "150ms" }} />
                  <span className="w-2 h-2 rounded-full bg-orange-500 animate-bounce" style={{ animationDelay: "300ms" }} />
                </div>
              ) : (
                <MessageContent content={msg.content} />
              )}
              {!msg.isTyping && (
                <p className="text-[10px] mt-1.5 opacity-50">
                  {formatTime(msg.timestamp)}
                </p>
              )}
            </div>

            {msg.role === "user" && (
              <div className="w-8 h-8 rounded-xl bg-[var(--bg-tertiary)] border border-[var(--border-primary)] flex items-center justify-center flex-shrink-0 mt-1 text-xs font-bold text-[var(--text-primary)]">
                AK
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Quick Prompts */}
      <div className="px-4 pb-2">
        <div className="flex gap-2 overflow-x-auto no-scrollbar pb-1">
          {quickPrompts.map((qp) => (
            <button
              key={qp.id}
              onClick={() => sendMessage(qp.prompt)}
              disabled={isLoading}
              className="flex-shrink-0 flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-medium bg-[var(--bg-tertiary)] border border-[var(--border-primary)] text-[var(--text-secondary)] hover:border-orange-500/50 hover:text-orange-400 transition-all disabled:opacity-50"
            >
              <span>{qp.icon}</span>
              {qp.label}
            </button>
          ))}
        </div>
      </div>

      {/* Input */}
      <div className="px-4 pb-4">
        <form onSubmit={handleSubmit} className="relative">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Ask about heat safety, activity, hydration..."
            disabled={isLoading}
            className="w-full pr-12 pl-4 py-3 text-sm rounded-xl bg-[var(--bg-card)] border border-[var(--border-primary)] text-[var(--text-primary)] placeholder:text-[var(--text-muted)] focus:outline-none focus:border-orange-500/60 transition-colors disabled:opacity-60"
          />
          <button
            type="submit"
            disabled={!input.trim() || isLoading}
            className="absolute right-2 top-1/2 -translate-y-1/2 w-8 h-8 rounded-lg bg-orange-500 flex items-center justify-center text-white transition-all hover:bg-orange-600 disabled:opacity-40 disabled:cursor-not-allowed"
          >
            {isLoading ? (
              <Loader2 className="w-4 h-4 animate-spin" />
            ) : (
              <Send className="w-4 h-4" />
            )}
          </button>
        </form>
      </div>
    </div>
  );
}
