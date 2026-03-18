<script setup lang="ts">
import { ref, onMounted } from 'vue';
// import HelloWorld from '../components/HelloWorld.vue';

// 留言类型定义
interface Message {
  _id: number;
  text: string;
  likes: number;
}

// 留言内容响应式变量
const myInput = ref<string>('');
// 留言列表
const messages = ref<Message[]>([]);
// 提交状态
const isSubmitting = ref<boolean>(false);
// 加载状态
const isLoading = ref<boolean>(false);

/**
 * 获取留言列表
 */
const fetchMessages = async () => {
  isLoading.value = true;
  try {
    const response = await fetch('/api/messages');
    if (!response.ok) {
      throw new Error(`获取留言失败: ${response.statusText}`);
    }
    const data = await response.json();
    messages.value = data;
  } catch (error) {
    console.error('获取留言列表出错:', error);
  } finally {
    isLoading.value = false;
  }
};

/**
 * 提交留言
 */
const submitMsg = async () => {
  const content = myInput.value.trim();
  
  if (!content) {
    alert('请输入留言内容');
    return;
  }

  isSubmitting.value = true;
  try {
    const response = await fetch('/api/messages', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: content })
    });

    if (!response.ok) {
      throw new Error(`提交失败: ${response.statusText}`);
    }

    alert('留言提交成功！');
    myInput.value = ''; // 提交成功后清空输入框
    await fetchMessages(); // 提交成功后重新获取列表
  } catch (error) {
    console.error('提交留言出错:', error);
    alert(error instanceof Error ? error.message : '提交过程中发生了未知错误');
  } finally {
    isSubmitting.value = false;
  }
};

/**
 * 点赞留言
 * @param id 留言 ID
 */
const likeMessage = async (id: number) => {
  try {
    const response = await fetch(`/api/messages/${id}/like`, {
      method: 'PATCH',
    });

    if (!response.ok) {
      throw new Error(`点赞失败: ${response.statusText}`);
    }

    // 乐观更新或重新拉取数据
    // 这里简单起见直接重新拉取数据，以保证数据一致性
    await fetchMessages();
  } catch (error) {
    console.error('点赞留言出错:', error);
    alert('点赞失败，请稍后重试');
  }
};

// 组件挂载时获取列表
onMounted(() => {
  fetchMessages();
});
</script>

<template>
  <div class="home">
    <div class="container">
      <h1>首页</h1>
      <!-- <HelloWorld msg="欢迎来到首页" /> -->

      <!-- 留言表单 -->
      <section class="comment-form-section">
        <h3>发表留言</h3>
        <div class="form-group">
          <textarea
            v-model="myInput"
            placeholder="写下你想说的话..."
            :disabled="isSubmitting"
            rows="4"
          ></textarea>
        </div>
        <button 
          @click="submitMsg" 
          :disabled="isSubmitting || !myInput.trim()"
          class="submit-btn"
        >
          {{ isSubmitting ? '提交中...' : '提交留言' }}
        </button>
      </section>

      <!-- 留言列表展示 -->
      <section class="comment-list-section">
        <h3>全部留言 ({{ messages.length }})</h3>
        
        <div v-if="isLoading && messages.length === 0" class="loading">
          正在加载留言...
        </div>
        
        <div v-else-if="messages.length === 0" class="empty-msg">
          暂无留言，快来抢沙发吧！
        </div>
        
        <ul v-else class="message-list">
          <li v-for="msg in messages" :key="msg._id" class="message-item">
            <div class="message-content">{{ msg.text }}</div>
            <div class="message-footer">
              <button @click="likeMessage(msg._id)" class="like-btn">
                <span class="heart">❤️</span>
                <span class="like-count">{{ msg.likes || 0 }}</span>
              </button>
            </div>
          </li>
        </ul>
      </section>
    </div>
  </div>
</template>

<style scoped>
.home {
  padding: 2rem;
  display: flex;
  justify-content: center;
}

.container {
  max-width: 600px;
  width: 100%;
  text-align: center;
}

.comment-form-section,
.comment-list-section {
  /* margin-top: 2rem; */
  padding: 1.5rem;
  border: 1px solid #eee;
  border-radius: 8px;
  background-color: #f9f9f9;
  text-align: left;
}

.comment-form-section h3,
.comment-list-section h3 {
  margin-top: 0;
  margin-bottom: 1rem;
  color: #333;
  border-bottom: 1px solid #eee;
  padding-bottom: 0.5rem;
}

.form-group {
  margin-bottom: 1rem;
}

textarea {
  width: 100%;
  padding: 0.8rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-family: inherit;
  font-size: 1rem;
  resize: vertical;
  box-sizing: border-box;
}

textarea:focus {
  outline: none;
  border-color: #646cff;
}

.submit-btn {
  background-color: #646cff;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.25s;
}

.submit-btn:hover {
  background-color: #535bf2;
}

.submit-btn:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

/* 留言列表样式 */
.message-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.message-item {
  padding: 1rem 0;
  border-bottom: 1px solid #eee;
}

.message-item:last-child {
  border-bottom: none;
}

.message-content {
  font-size: 1rem;
  color: #444;
  line-height: 1.5;
  margin-bottom: 0.8rem;
  word-break: break-all;
}

.message-footer {
  display: flex;
  justify-content: flex-end;
}

.like-btn {
  background-color: white;
  border: 1px solid #ddd;
  padding: 0.3rem 0.8rem;
  border-radius: 20px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  transition: all 0.2s;
  font-size: 0.9rem;
}

.like-btn:hover {
  border-color: #ff4757;
  color: #ff4757;
  background-color: #fffafb;
}

.heart {
  font-size: 1rem;
}

.like-count {
  font-weight: bold;
}

.loading, .empty-msg {
  text-align: center;
  padding: 2rem;
  color: #888;
}
</style>
