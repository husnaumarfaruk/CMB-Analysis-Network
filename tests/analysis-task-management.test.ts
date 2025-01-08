import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let taskCount = 0;
const analysisTasks = new Map();

// Simulated contract functions
function createAnalysisTask(datasetId: number, algorithmId: number, name: string, description: string, creator: string) {
  const taskId = ++taskCount;
  analysisTasks.set(taskId, {
    creator,
    datasetId,
    algorithmId,
    name,
    description,
    status: 'pending',
    resultHash: null,
    timestamp: Date.now()
  });
  return taskId;
}

function updateTaskStatus(taskId: number, newStatus: string, updater: string) {
  const task = analysisTasks.get(taskId);
  if (!task) throw new Error('Invalid task');
  if (updater !== 'CONTRACT_OWNER' && updater !== task.creator) throw new Error('Not authorized');
  task.status = newStatus;
  analysisTasks.set(taskId, task);
  return true;
}

function setTaskResult(taskId: number, resultHash: string, updater: string) {
  const task = analysisTasks.get(taskId);
  if (!task) throw new Error('Invalid task');
  if (updater !== task.creator) throw new Error('Not authorized');
  task.status = 'completed';
  task.resultHash = resultHash;
  analysisTasks.set(taskId, task);
  return true;
}

describe('Analysis Task Management Contract', () => {
  beforeEach(() => {
    taskCount = 0;
    analysisTasks.clear();
  });
  
  it('should create a new analysis task', () => {
    const taskId = createAnalysisTask(1, 1, 'WMAP Analysis', 'Analyze WMAP data for anomalies', 'user1');
    expect(taskId).toBe(1);
    expect(analysisTasks.size).toBe(1);
    const task = analysisTasks.get(taskId);
    expect(task.name).toBe('WMAP Analysis');
    expect(task.status).toBe('pending');
  });
  
  it('should update task status', () => {
    const taskId = createAnalysisTask(2, 2, 'Planck Analysis', 'Analyze Planck data for cold spots', 'user2');
    expect(updateTaskStatus(taskId, 'processing', 'CONTRACT_OWNER')).toBe(true);
    const task = analysisTasks.get(taskId);
    expect(task.status).toBe('processing');
  });
  
  it('should set task result', () => {
    const taskId = createAnalysisTask(3, 3, 'COBE Analysis', 'Analyze COBE data for temperature fluctuations', 'user3');
    expect(setTaskResult(taskId, '0x1234567890abcdef', 'user3')).toBe(true);
    const task = analysisTasks.get(taskId);
    expect(task.status).toBe('completed');
    expect(task.resultHash).toBe('0x1234567890abcdef');
  });
  
  it('should not allow unauthorized status updates', () => {
    const taskId = createAnalysisTask(4, 4, 'ACT Analysis', 'Analyze ACT data for small-scale structure', 'user4');
    expect(() => updateTaskStatus(taskId, 'processing', 'unauthorized_user')).toThrow('Not authorized');
  });
  
  it('should not allow unauthorized result updates', () => {
    const taskId = createAnalysisTask(5, 5, 'SPT Analysis', 'Analyze SPT data for galaxy clusters', 'user5');
    expect(() => setTaskResult(taskId, '0xabcdef1234567890', 'unauthorized_user')).toThrow('Not authorized');
  });
});

